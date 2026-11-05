export interface LocalQuoteLine {
  readonly productCode?: string;
  readonly description: string;
  readonly unit: string;
  readonly quantity: string;
  readonly netUnitPrice: string;
  readonly discountPercent: string;
  readonly priceList?: string;
  readonly sourceVersion?: string;
}

export interface LocalQuoteDraft {
  readonly owner: string;
  readonly id: string;
  readonly revision: number;
  readonly updatedUtc: string;
  readonly customerCode: string;
  readonly customerName: string;
  readonly currency: string;
  readonly taxRate: string;
  readonly lines: readonly LocalQuoteLine[];
}

export function openQuoteDrafts(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open("dayr-field-quotes", 1);
    request.onupgradeneeded = () => {
      request.result.createObjectStore("drafts", { keyPath: ["owner", "id"] });
    };
    request.onerror = () => reject(request.error);
    request.onsuccess = () => {
      request.result.onversionchange = () => request.result.close();
      resolve(request.result);
    };
  });
}

export function listQuoteDrafts(db: IDBDatabase, owner: string): Promise<LocalQuoteDraft[]> {
  return new Promise((resolve, reject) => {
    const tx = db.transaction("drafts", "readonly");
    const range = IDBKeyRange.bound([owner], [owner, []], false, true);
    const request = tx.objectStore("drafts").getAll(range);
    tx.onabort = () => reject(tx.error);
    tx.oncomplete = () => resolve(request.result);
  });
}

/** owner must come from the locally verified session, never from editable form input. */
export function saveQuoteDraft(
  db: IDBDatabase,
  owner: string,
  draft: Omit<LocalQuoteDraft, "owner" | "revision" | "updatedUtc">,
  expectedRevision: number,
): Promise<LocalQuoteDraft> {
  return new Promise((resolve, reject) => {
    if (!owner || !draft.id) throw new Error("Missing draft identity.");
    const tx = db.transaction("drafts", "readwrite");
    const store = tx.objectStore("drafts");
    const read = store.get([owner, draft.id]);
    let conflict = false;
    let saved: LocalQuoteDraft;
    tx.onabort = () => reject(conflict ? new Error("Draft revision conflict.") : tx.error);
    tx.oncomplete = () => resolve(saved);
    read.onsuccess = () => {
      const current = read.result as LocalQuoteDraft | undefined;
      if ((current?.revision ?? 0) !== expectedRevision) {
        conflict = true;
        tx.abort();
        return;
      }
      saved = { ...draft, owner, revision: expectedRevision + 1, updatedUtc: new Date().toISOString() };
      store.put(saved);
    };
  });
}

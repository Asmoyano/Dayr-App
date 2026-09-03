const API_BASE_URL = 'https://localhost:7216';

export interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

export async function obtenerClima(): Promise<WeatherForecast[]> {
  try {
    const respuesta = await fetch(`${API_BASE_URL}/weatherforecast`);
    if (!respuesta.ok) {
      throw new Error(`Error en la solicitud: ${respuesta.status}`);
    }
    return await respuesta.json();
  } catch (error) {
    console.error('Error al conectar con la API:', error);
    throw error;
  }
}
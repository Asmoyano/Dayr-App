import { apiClient } from './client';
import { type HealthCheckResponse } from '../types/api.types';

export const checkApiHealth = async (): Promise<HealthCheckResponse> => {
  try {
    const response = await apiClient.get<HealthCheckResponse>('/health');
    return response.data;
  } catch (error) {
    throw error;
  }
};
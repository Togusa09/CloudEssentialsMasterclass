import axios from 'axios';
import { config } from './config';

const httpClient = axios.create({
    baseURL: config.apiUrl,
    withCredentials: false,
})

export const http = {
    get: async <T>(url: string): Promise<T> => httpClient.get<T>(url).then(res => res.data)
}
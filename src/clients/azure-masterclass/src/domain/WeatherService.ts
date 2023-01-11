import { http } from './http'

export type WeatherForecast = {
    dateTime: Date
    temperatureC: number
    temperatureF: number
    summary?: string
}

export const WeatherService = {
    getWeather: () => http.get<WeatherForecast>('/weatherforecast'),
}

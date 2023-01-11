interface AppConfig {
    apiUrl: string
}

console.log("process.env.NODE_ENV", process.env.NODE_ENV)

// See: process.env.NODE_ENV in https://create-react-app.dev/docs/adding-custom-environment-variables/
const isDev = process.env.NODE_ENV === 'development'

export const config: AppConfig = (window as any).appConfig as AppConfig || {
    apiUrl: isDev ? 'https://localhost:5001' : '',
}
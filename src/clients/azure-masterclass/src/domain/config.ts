interface AppConfig {
    apiUrl: string
  }
  
  export const config: AppConfig = (window as any).appConfig as AppConfig || {
    apiUrl: '',
  }
import React, { useEffect, useState } from 'react';
import logo from './logo.svg';
import './App.css';
import { WeatherForecast, WeatherService } from './domain/WeatherService';

function App() {
  const [weather, setWeather] = useState<WeatherForecast>()

  useEffect(() => {
    console.log('useEffect')
    WeatherService.getWeather().then((weather => {
      setWeather(weather)
    }))
  }, [])

  console.log('weather', weather)

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
      </header>
      <div className="Weather"><pre>{JSON.stringify(weather, null, 2)}</pre></div>
    </div>
  );
}

export default App;

# Tongi - Translation Optimized Naturally Guided by IA.

A Flutter-based translation application with C++ backend and microservices integration for audio, text, and translation services.

## Authors

- **Juan David Patiño Parra** - juandavidp1127@gmail.com  
- **Juan David Carvajal Rondón** - juandacr25@gmail.com  
- **Christian Mauricio Rodriguez Curubo** - cmrcurubo@gmail.com  
- **Jose Daniel Montero Gutierrez** - jmontero.gutierrez2002@gmail.com  

---
## Project Structure

```
Tongi/
├── frontend/               # Flutter mobile application
│   ├── lib/
│   │   ├── core/          # Core utilities (colors, languages, styles)
│   │   ├── screens/       # App screens (audio, text, settings)
│   │   ├── services/      # App services (record service)
│   │   └── widgets/       # Reusable UI components
│   ├── assets/
│   │   ├── fonts/         # Custom fonts (Poppins, NotoSans)
│   │   └── images/        # App images
│   └── pubspec.yaml       # Flutter dependencies
│
├── backend/               # C++ REST API server
│   ├── main.cpp          # Server entry point
│   ├── CMakeLists.txt    # Build configuration
│   ├── Dockerfile        # Container configuration
│   └── config.json       # Server configuration
│
└── servers/              # Server management scripts
    ├── run_all.bat       # Run all services
    ├── run_stt.bat       # Speech-to-text service
    ├── run_tts.bat       # Text-to-speech service
    └── run_ttt.bat       # Text-to-text translation
```
## Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![C++](https://img.shields.io/badge/c++-%2300599C.svg?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![CMake](https://img.shields.io/badge/CMake-%23008FBA.svg?style=for-the-badge&logo=cmake&logoColor=white)

## Features

- **Audio Translation**: Record and translate spoken language
- **Text Translation**: Type and translate text between languages
- **Multi-language Support**: Support for multiple languages
- **Custom UI**: Clean interface with Poppins and NotoSans fonts
- **Settings**: Language preferences and app configuration


---
## License

This is a private project developed for academic and experimental purposes.

Anyways, authors ask for respect by **not using, copying, or distributing this code without explicit permission**.

---
*Tongi - All rights reserved for the authors* 🌐

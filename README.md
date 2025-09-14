# Knowble: Your Smart Learning Companion

![Knowble Logo](assets/images/logo%203.png)

Knowble is a Flutter-based EdTech mobile application that revolutionizes digital learning through AI integration and smart features. Built with Flutter for cross-platform compatibility and powered by Supabase for real-time data management, Knowble delivers a seamless learning experience with features like AI-generated quizzes, personalized course recommendations, real-time chat support, and intelligent scheduling tools.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Database-green.svg)](https://supabase.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Table of Contents

- [About the Project](#about-the-project)
- [Problem Statement](#problem-statement)
- [Objectives](#objectives)
- [Main Features](#main-features)
- [Project ER Diagram](#project-er-diagram)
- [Tentative UI Screens](#tentative-ui-screens)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [Team](#team)
- [License](#license)
- [Contact](#contact)

## About the Project

Knowble stands out by addressing common shortcomings in existing online learning platforms. It focuses on combining intelligent automation, real-time communication, and personalized tools to empower both students and instructors, making education more flexible, interactive, and personalized than ever before.

## Problem Statement

Despite the proliferation of online learning platforms, many lack truly interactive, personalized, and efficient learning experiences. Key issues include:
* **Limited AI chatbot functionality:** Most platforms offer basic chatbots incapable of explaining complex course content.
* **Manual and time-consuming quiz creation:** Instructors often face a heavy workload due to manual quiz creation, limiting dynamic assessments.
* **Ineffective communication channels:** Communication is often restricted to forums, preventing timely and personalized feedback.
* **Lack of personalized scheduling and progress tracking:** Current features don't adapt to individual learning habits, hindering motivation and organization.

Knowble aims to solve these challenges by providing a smarter, learner-focused solution.

## Objectives

* To provide learning opportunities for individuals of all ages.
* To help students stay consistent using a study scheduler.
* To establish efficient communication channels for interactive learning.

## Main Features

Knowble offers a comprehensive set of features designed for modern education:

### For Students
* **Smart Course Discovery:** 
  - Advanced search with filters and recommendations
  - Course previews and detailed information
  - Easy enrollment process
  
* **Learning Tools:**
  - Download and view course materials (PDFs, videos)
  - Interactive quizzes with instant feedback
  - Progress tracking and achievements
  - Digital certificates upon course completion

* **Study Management:**
  - Smart scheduling with reminders
  - Customizable study planner
  - Progress analytics and insights
  - Local notifications for deadlines

### For Instructors
* **Course Management:**
  - Intuitive course creation interface
  - Multiple content type support (PDF, video, slides)
  - Student progress monitoring
  - Engagement analytics

* **Communication Tools:**
  - Real-time chat with students
  - Announcement system
  - Feedback mechanism
  - Group discussions

### Core Features
* **AI Integration:**
  - Smart content recommendations
  - Automated quiz generation
  - Intelligent study planning
  - 24/7 AI tutoring support

* **Security & Performance:**
  - Secure authentication
  - Offline content access
  - Cross-platform compatibility
  - Real-time data sync

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

* Flutter SDK (3.0 or higher)
* Dart SDK (Latest stable version)
* Android Studio / VS Code with Flutter extension
* Supabase account (for database and authentication)
* Google Cloud Project (for Gemini API access)

### Installation

1.  Clone the repo:
    ```bash
    git clone https://github.com/Sii-fu/knowble.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd knowble
    ```
3.  Install Flutter dependencies:
    ```bash
    flutter pub get
    ```
4.  Set up environment variables: Create a `.env` file in the root directory and add your configuration:
    ```
    SUPABASE_URL=YOUR_SUPABASE_URL
    SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
    GEMINI_API_KEY=YOUR_GEMINI_API_KEY
    ```
5.  Run the application:
    ```bash
    flutter run
    ```

### Building for Production

To build the release version:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## Usage

(Coming Soon: Detailed instructions on how to use the app for students, instructors, and admins.)

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## Team

Meet our talented team of developers:

* **Sifat Bin Asad** ([@Sii-fu](https://github.com/Sii-fu))
* **Mehnaj Hridi** ([@mehnaj-hridi](https://github.com/mehnaj-hridi))
* **Progga Laboni Ray** ([@mika-progga](https://github.com/mika-progga))
* **Reefah Tasnia Haque** ([@reefahtasnia ](https://github.com/reefahtasnia))

## Technical Stack

- **Frontend**: Flutter, Dart
- **Backend**: Node.js, Express
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **AI Integration**: Google Gemini API
- **Storage**: Supabase Storage
- **Notifications**: Flutter Local Notifications
- **State Management**: Provider
- **UI Components**: Material Design, Custom Widgets

## License

Distributed under the MIT License. See `LICENSE` for more information.
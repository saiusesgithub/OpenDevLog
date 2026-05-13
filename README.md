# Open DevLog

A modern, open-source daily developer log and journaling application built with Flutter. Open DevLog is designed to help developers seamlessly record their daily progress, track blockers, generate AI-powered summaries, and synchronize their logs directly with GitHub.

## Features

- 📝 **Markdown Editor**: A rich daily journal editor supporting markdown formatting with local auto-save capabilities.
- ✨ **AI Summary Generation**: Automatically generate daily summaries from your raw notes, categorizing accomplishments, blockers, and ideas.
- 🔄 **GitHub Sync**: Connect to your GitHub account and synchronize your daily logs to a remote repository effortlessly.
- 📊 **Insights & History**: View your entry history, track streaks, and visualize insights into your development habits.
- 📅 **Calendar View**: Easily navigate and review past entries using the integrated calendar interface.
- 🎨 **Sleek UI**: A beautiful dark theme featuring glassmorphism elements, glowing borders, and responsive design for both desktop and mobile platforms.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.11.4)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/opendevlog.git
   cd opendevlog
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

The project follows a feature-based directory structure inside the `lib/` folder:

- `core/`: Contains core application settings such as themes.
- `screens/`: Contains all the main UI screens (e.g., Journal, Calendar, GitHub Sync).
- `widgets/`: Reusable custom UI components like `GlassCard` and `GlowingBorder`.
- `main.dart`: The main entry point of the application.

## Technologies Used

- [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications
- [Lucide Icons](https://pub.dev/packages/lucide_icons) - Beautiful and consistent icon set
- [Google Fonts](https://pub.dev/packages/google_fonts) - Typography

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

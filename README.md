# Moon Cosmetics & Beauty Shop — Windows POS

Production-oriented Flutter Windows POS project.

## Important: GitHub upload

**Do not upload this ZIP file as a single file and expect GitHub to extract it.**
GitHub's web uploader stores a ZIP as a ZIP; it does not turn it into a repository.

Instead:

1. Create a new GitHub repository.
2. Extract this ZIP on your computer.
3. Open the extracted project folder.
4. Upload the **contents of the project folder** to the repository root, including:
   - `pubspec.yaml`
   - `lib/`
   - `assets/`
   - `database/`
   - `.github/workflows/windows-build.yml`
   - `.gitignore`
5. Commit the files to `main`.
6. Open **Actions** in GitHub.
7. Select **Moon Cosmetics POS - Windows Build**.
8. When the workflow succeeds, open the run and download the artifact named:
   `moon_cosmetics_pos-windows`

The artifact is a ZIP containing the complete Flutter Windows Release folder. Keep all files in that folder together; do not distribute only the EXE.

## Dependency compatibility

The project uses `postgres: ^3.4.8` because the GitHub build environment used by this project is Flutter 3.22.0 / Dart 3.4.x. Do not change it to PostgreSQL package 3.5.x unless the Flutter/Dart SDK is upgraded and the dependency set is re-tested.

## Database

The application connects to PostgreSQL. Default development settings are:

- Host: `127.0.0.1`
- Port: `5432`
- Database: `moon_cosmetics`
- User: `postgres`
- Password: empty by default

For a real deployment, pass credentials at build/run time rather than hard-coding production passwords.

## Local Windows build

Install Visual Studio 2022 with **Desktop development with C++** and a Windows SDK, then run:

```powershell
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
```

The release application is under:

`build/windows/x64/runner/Release/`

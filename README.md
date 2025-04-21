# Godot Project Setup for Windows

This is a simple guide to set up the Godot project on your Windows computer and configure Visual Studio Code (VS Code) for development.

## Prerequisites

Before running the project, you will need the following installed:

- [Godot Engine](https://godotengine.org/download) (Version used: **X.X.X**)
- [Git](https://git-scm.com/)
- [Visual Studio Code](https://code.visualstudio.com/)

## Clone the Repository

1. First, clone this repository to your local machine by running the following command in your terminal or Git Bash:

    ```bash
    git clone https://github.com/your-username/your-repo-name.git
    ```

2. Navigate to the project folder:

    ```bash
    cd your-repo-name
    ```

## Setting up the Project in Godot

1. Open **Godot Engine**.

2. In Godot, click **"Import"** on the project manager screen.

3. Select the `project.godot` file in the cloned project folder.

4. Click **"Open"** to load the project.

## Running the Project

1. Once the project is open in Godot, click the **"Play"** button (the green triangle) to run the project.

## Setting up Visual Studio Code

To enhance your development experience with Visual Studio Code, follow these steps:

### 1. Install Godot VS Code Plugin

Install the **Godot Tools** extension for VS Code to enable better integration with Godot. This extension adds syntax highlighting, code completion, debugging support, and more.

- Go to the [Godot Tools extension page](https://marketplace.visualstudio.com/items?itemName=justdan01.godot-tools).
- Click **Install** to add it to VS Code.

### 2. Open the Project in VS Code

1. Launch **Visual Studio Code**.
2. Open the project folder by clicking **File > Open Folder** and selecting the cloned project folder.
3. If you are using **GDScript**, VS Code should automatically detect it and provide you with syntax highlighting.

### 3. Code Formatting (Optional)

If you want to automatically format your code, you can install **Prettier** or use Godot’s built-in formatting options. This step is optional but recommended for a cleaner codebase.

## Building the Project for Windows

If you'd like to export the game for Windows, follow these steps:

1. In Godot, go to **Project > Export**.
2. Choose **Windows Desktop** as the target platform.
3. Click **"Export Project"** and select a location to save the `.exe` file.
4. Share the `.exe` and accompanying files with

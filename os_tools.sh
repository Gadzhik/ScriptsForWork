#!/usr/bin/env bash

# Checking for sudo and required packages
if ! command -v sudo &> /dev/null; then
  echo "Error: The script requires using sudo."
  exit 1
fi

required_packages="iproute2"
for pkg in $required_packages; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        echo "Error: Package not installed '$pkg'. Please, install it using apt-get install $pkg."
        exit 1
    fi
done

# Checking write permissions in /etc/sudoers.d/
if [[ ! -w /etc/sudoers.d ]]; then
  echo "Error: No permission to write to /etc/sudoers.d/. Please, run script with sudo."
  exit 1
fi

# Menu
show_menu() {
  echo ""
  echo "====================================="
  echo "          System Menu"
  echo "====================================="
  echo "1. Create superuser with SSH access"
  echo "2. Remane OS and update /etc/hosts, /etc/hostname"
  echo "3. Show IP addresses for interfaces"
  echo "4. Show routes"
  echo "5. Show folder contents (for example mediaserver/, need to specify the path)"
  echo "6. Delete folder contents (need to specify the path)"
  echo "7. Delete package (dpkg)"
  echo "8. Delete programm (apt)"
  echo "9. Copy files via scp"
  echo "10. Exit"
  echo ""
}

# Creating a superuser with SSH access
create_user() {
  read -p "Enter username " username

  if id -u "$username" &> /dev/null; then
    echo "Error: User '$username' already exists."
    return 1
  fi

  sudo useradd -m -s /bin/bash "$username"
  echo "$username:$username" | sudo chpasswd
  sudo usermod -aG sudo "$username"

  echo "User '$username' created and added to the sudo group, password for the added user - username. SSH access is configured."
}

# Renaming the OS and updating configuration files
rename_os() {
  read -p "Enter new name for OS: " new_hostname

  if [ -z "$new_hostname" ]; then
    echo "Error: OS name cannot be empty"
    return 1
  fi

  sudo hostnamectl set-hostname "$new_hostname"
  echo "$new_hostname" | sudo tee /etc/hostname > /dev/null
  sudo sed -i "s/^127.0.1.1.*/127.0.1.1\t$new_hostname/g" /etc/hosts

  read -p "Do you want to reboot your system to apply the changes? (y/n): " restart_choice
  if [[ "$restart_choice" == "y" || "$restart_choice" == "Y" ]]; then
    sudo reboot
  fi
}

# Displaying IP addresses of interfaces
show_ips() {
  ip -o a
}

# Displaying routes
show_routes() {
  ip route show
}

# Displaying folder contents
show_directory() {
  read -p "Enter the path to the folder: " directory

  if [ ! -d "$directory" ]; then
    echo "Error: The specified folder does not exist."
    return 1
  fi

  ls -la "$directory"
}

# Delete folder contents
delete_directory_content() {
  read -p "Enter the path to the folder to delete (be careful!): " directory

  if [ ! -d "$directory" ]; then
    echo "Error: The specified folder does not exist."
    return 1
  fi

  read -p "Confirm deletion of the folder contents '$directory'? (y/n): " confirmation
  if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
      echo "Deletion cancelled."
      return 1
  fi

    find "$directory" -type f -delete
    find "$directory" -type d -empty -delete #delete empty directories

  echo "Content for '$directory' delete."
}

# Package delete (dpkg)
remove_package() {
  read -p "Enter the name of the package to remove: " package_name

  if ! dpkg -s "$package_name" &> /dev/null; then
    echo "Error: Package '$package_name' not found."
    return 1
  fi

  sudo apt-get remove --purge "$package_name" -y #use purge to remove all files

  echo "Package '$package_name' deleted."
}

# Delete programm (apt)
remove_program() {
   read -p "Enter the name of the program to remove: " program_name

   if ! dpkg -s "$program_name" &> /dev/null; then
    echo "Error: Programm '$program_name' not found."
    return 1
  fi

  sudo apt-get remove --purge "$program_name" -y #use purge to remove all files

  echo "Programm '$program_name' deleted."
}

# File copying via scp
copy_files_scp() {
   read -p "Enter the username on the remote server: " remote_user
   read -p "Enter the remote server address (e.g. server.com or IP): " remote_address
   read -p "Enter the path to the folder with file to copy from your local computer (ex. /home/user/file.txt): " local_file
   read -p "Enter the path to the folder to copy on the remote server (ex. /home/user/): " remote_dir

  if [ ! -f "$local_file" ]; then
    echo "Error: Local file/folder does not exist."
    return 1
  fi

  scp -r "$local_file" "$remote_user@$remote_address:$remote_dir"

  echo "Files have been copied to the remote server."

}

# The ... script
while true; do
  show_menu
  read -p "Select action (1-10): " choice

  case $choice in
    1) create_user ;;
    2) rename_os ;;
    3) show_ips ;;
    4) show_routes ;;
    5) show_directory ;;
    6) delete_directory_content ;;
    7) remove_package ;;
    8) remove_program ;;
    9) copy_files_scp ;;
    10) echo "Exit..." ; exit 0 ;;
    *) echo "Incorrect selection. Please enter a number between 1 and 10." ;;
  esac

  read -p "Repeat? (y/n): " repeat
  if [[ "$repeat" != "y" && "$repeat" != "Y" ]]; then
    echo "Open Main Menu?"
    exit 0
  fi
done
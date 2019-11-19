#!/bin/sh
# This script configures the system environment for a user
# who has just downloaded RPM. It works for Linux, OSX,
# Git Bash (MGW64) and several other systems.

# What this script does:
# 1. Checks its runtime environment.
# 2. Copies pre-commit to .git/hooks directory.
# 3. Adds alias for google-java-format-X.X-all-deps.jar to
#    ~/.bashrc or ~/.bash_profile ~/tcshrc depending on environment.

# Use uname (Unix name) -s (system) to retrieve information about the current system (typically the OS or kernel)
# uname is part of the POSIX standard, meaning that there is a high degree of certainty that it is implemented and
# consistently so on *nix systems.
sys_env=$(uname -s)
number_of_files=""
jar_path=""
jar_version="1.7"

#####################################
#          Functions                #
#####################################

# Add_alias_to_* functions target a specific shell based on the detected system. They append the path to the
# google style formatter JAR to the shell's respective configuration file.
# Please note that due to the number of possible shell environments that could be installed, only the expected 
# defaults for each system are configured. If you're using a different shell, please consult its documentation for 
# how to configure it.

add_alias_to_bash_profile() {
  grep -q "alias google-style-formatter" "$HOME/.bash_profile";
  if [ "$?" -eq 0 ]; then
    echo "Alias already exists.";
    exit 0;
  fi
  echo "Adding alias to $HOME/.bash_profile";
  echo "# Google Java Style Formatter JAR alias" >> "$HOME/.bash_profile";
  echo "alias google-style-formatter=\"java -jar $jar_path/google-java-format-$jar_version-all-deps.jar\"" >> "$HOME/.bash_profile";
  echo "Alias successfully added!";
  echo "Execute \"source \$HOME/.bash_profile\" to start using the google style formatter on the command line";
}

add_alias_to_bashrc() {
  grep -q "alias google-style-formatter" "$HOME/.bashrc";
  if [ "$?" -eq 0 ]; then
    echo "Alias already exists.";
    exit 0;
  fi
  echo "Adding alias to $HOME/.bashrc";
  echo "# Google Java Style Formatter JAR alias" >> "$HOME/.bashrc";
  echo "alias google-style-formatter=\"java -jar $jar_path/google-java-format-$jar_version-all-deps.jar\"" >> "$HOME/.bashrc";
  echo "Alias successfully added!";
  echo "Execute \"source \$HOME/.bashrc\" to start using the google style formatter on the command line";
}

add_alias_to_tcsh() {
  grep -q "alias google-style-formatter" "$HOME/.tcshrc";
  if [ "$?" -eq 0 ]; then
    echo "Alias already exists.";
    exit 0;
  fi
  echo "Adding alias to $HOME/.cshrc";
  echo "# Google Java Style Formatter JAR alias" >> "$HOME/.cshrc";
  echo "alias google-style-formatter=\"java -jar $jar_path/google-java-format-$jar_version-all-deps.jar\"" >> "$HOME/.cshrc";
  echo "Alias successfully added!";
  echo "Execute \"source \$HOME/.cshrc\" to start using the google style formatter on the command line";
}

# A local function that prints an error when no Java installation is found.
# Prints to STDERR (file descriptor 2) and then exits the program with a exit code of 1.
err_no_java() {
  echo "Java is either not installed or it is not in your system's PATH variable." >&2;
  exit 1;
}

# A local function that prints an error when cp fails to copy the pre-commit hook to .git/hooks.
err_copy_failed() {
  echo "Copying pre-commit to .git/hooks has failed." >&2;
  exit 2;
}


#############################
#                           #
#          Start            #
#                           #
#############################

# Checks if the system has Java installed.
# Calls err_no_java if no java installation is found.
command -v java > "/dev/null" 2>&1;
  if [ "$?" -gt 0 ]; then
    err_no_java
  fi
echo "Java installation found!";

# Get the absolute path of the .env-config directory.
# Despite being legacy, realpath is used because it is POSIX-compliant.
# Furthermore, the alternative, readlink, does not exist on OSX.
# PWD is used as a backup, as the user should be in the meta repo directory
# when executing this script, and it is also included in the POSIX standard.
command -v realpath > "/dev/null" 2>&1;
if [ "$?" -gt 0 ]; then
  echo "Realpath is not available on this machine. Trying another method.";
  jar_path="$(pwd -P)/.env-config"; 
else
  jar_path="$(realpath .env-config)";
fi

# Iterate through all repos and copy the .env-config folder,
# copy pre-commit to .gitignore, and copy .env-config to repo.
for f in *; do
  if [ -d "$f" ]; then
    # Copy pre-commit to .git/hooks/
    echo "Copying pre-commit to $f/.git/hooks/";
    cp "$jar_path/pre-commit" "$f/.git/hooks/";
    if [ "$?" -gt 0 ]; then
      err_copy_failed
    fi
    echo "Copy of pre-commit hook to $f/.git/hooks was successful.";
  fi
done;

# Create alias for google-java-formatter JAR
case $sys_env in
  Linux)
      add_alias_to_bashrc
    ;;

  Darwin)
      add_alias_to_bash_profile
    ;;

  FreeBSD)
      add_alias_to_tcsh
    ;;

  MINGW64_NT*)
      add_alias_to_bash_profile
    ;;

  *)
    echo "Automated alias generation for $sys_env is unsupported at this time. Try manually invoking the JAR file. If you have the know-how, please consider adding the code necessary to add this functionality.";
    exit 3;
esac
exit 0;

#!/bin/bash

echo "Enter the path to the directory you want to scan:"
read path

echo "Enter description:"
read desc

output_file="output.md"

>$output_file

function main() {
  write_module_tree $path
  write_source_code $path
  create_gist
}

function write_module_tree() {
  echo "# Module Tree" >$output_file
  echo '```' >>$output_file
  tree -I 'output.md|*.git*' "$1" >>$output_file
  echo '```' >>$output_file
}

function write_source_code() {
  echo "# Source Code" >>$output_file

  files=$(find "$1" -type f -name "*.go" | sort)

  current_package=""
  for file in $files; do
    file_path=${file%.go}
    package=$(dirname $file_path)
    if [ "$package" != "$current_package" ]; then
      current_package="$package"
      package_pretty=$(echo "$current_package" | sed 's|./||') # Remove ./ from package name
      echo "## Package: \`$package_pretty\`" >>$output_file
    fi

    echo "### Source File: \`$file_path.go\`" >>$output_file
    echo '```go' >>$output_file
    cat $file >>$output_file
    echo '```' >>$output_file
  done
}

function create_gist() {
  echo "Creating gist..."
  gist_url=$(gh gist create --public --desc "$desc" $output_file)
  echo "Gist created at: $gist_url"
}

main

# Changes made in "Godot Engine for creation of Melvin 4.4.1"

# Files Added
`Project-Build.md`

# Files Modified

## <code style="color : lightgreen">Non-Code Files</code>

**Saved with CRLF**

.clang-format  
.clang-tidy  
.clangd  
.editorconfig  
.gitattributes  
.gitignore  
.pre-commit-config.yaml  
SConstruct  
godot.manifest  
AUTHORS.md  
CHANGELOG.md  
CONTRIBUTING.md  
DONORS.md  
README.md  
version.py  
COPYRIGHT.txt  
LICENSE.txt  
LOGO_LICENSE.txt  
mailmap.txt  


### `.gitattributes`

**At line 6**

```
#Normalize EOL for all files that Git considers text files
* text=auto eol=crlf
# Except for Windows-only / Visual Studio files
*.bat eol=crlf
*.sln eol=crlf
*.csproj eol=crlf
misc/msvs/* eol=crlf
# And some test files where the EOL matters
*.test.txt -text
```
*because of my edits the last one could break*

### `.editorconfig`

**at line 5**
```toml
end_of_line = crlf
indent_size = 3
indent_style = tab
```

**At line 15**
```toml
[*.sh]
end_of_line = lf
```

### `AUTHORS.md`

**At line 32**

```md
## Custom Build Maker

	 Alec Benjamin (Alec269)

```

## <code style="color : lightblue">Code Files</code>
**Changed File EOL in**  
`modules\mono\editor\script_templates\`  
`modules\gdscript\editor\script_templates`  

### `core\io\file_access.cpp`

**Line 497:**  

```cpp
//default
//line += get_line() + "\n";
//#custom
line += get_line() + "\r\n";
```

**After Line 784:**

```cpp
//$ default
// bool FileAccess::store_line(const String &p_line) {
//     return store_string(p_line) && store_8('\n');
// }
//! customised for Windows
bool FileAccess::store_line(const String &p_line) {
    // #ifdef WINDOWS_ENABLED
    return store_string(p_line) && store_8('\r') && store_8('\n'); // CRLF for Windows
    // #else
    //      return store_string(p_line) && store_8('\n');  // LF for bad platforms
    // #endif
}
```

-----

### `scene\resources\resource_format_text.cpp`

**After Line 1951:**

```cpp
//f->store_string(name.property_name_encode() + " = " + vars + "\n");
         //# custom
         // #ifdef WINDOWS_ENABLED
         f->store_string(name.property_name_encode() + " = " + vars + "\r\n");
         // #else
         //      f->store_string(name.property_name_encode() + " = " + vars + "\n");
         // #endif
```

**After Line 2039:**

```cpp
//default
//f->store_string(String(state->get_node_property_name(i, j)).property_name_encode() + " = " + vars + "\n");
         //#custom
         f->store_string(String(state->get_node_property_name(i, j)).property_name_encode() + " = " + vars + "\r\n");
```

-----

### `editor\gui\code_editor.cpp`

**After Line 1252:**

```cpp
// Length 0 means it's already an empty line, no need to add a newline.
// if (line.length() > 0 && !line.ends_with("\n")) {
//      //default
//      //text_editor->insert_text("\n", final_line, line.length(), false);
// }
if (line.length() > 0 && !line.ends_with("\r\n") && !line.ends_with("\n")) {
    text_editor->insert_text("\r\n", final_line, line.length(), false);
}
```

-----

### `modules\gdscript\gdscript.cpp`

**At Line 3099:**

```cpp
       //default
       // int insert_idx = 0;
       // for (int i = 0; i < current.start_line - 1; i++) {
       //    insert_idx = source.find("\n", insert_idx) + 1;
       // }
       //#custom
       int insert_idx = 0;
       for (int i = 0; i < current.start_line - 1; i++) {
          // Look for both CRLF and LF
          int lf_pos = source.find("\n", insert_idx);
          int crlf_pos = source.find("\r\n", insert_idx);

          if (crlf_pos != -1 && (lf_pos == -1 || crlf_pos < lf_pos)) {
              insert_idx = crlf_pos + 2; // Skip \r\n
          } else if (lf_pos != -1) {
              insert_idx = lf_pos + 1; // Skip \n
          } else {
              break; // No more line endings found
          }
       }
```

-----

### `core\string\ustring.cpp`

**At Line 827:**

```cpp
String String::get_with_code_lines() const {
    String normalized = this->replace("\r\n", "\n");
    const Vector<String> lines = normalized.split("\n");
    String ret;
    for (int i = 0; i < lines.size(); i++) {
        if (i > 0) {
           ret += "\r\n"; // FIX - Use CRLF for output
        }
        ret += vformat("%4d | %s", i + 1, lines[i]);
    }
    return ret;
}
```

**At Line 4266:**

```cpp
String String::dedent() const {
    String new_string;
    String indent;
    bool has_indent = false;
    bool has_text = false;
    int line_start = 0;
    int indent_stop = -1;

    for (int i = 0; i < length(); i++) {
        char32_t c = operator[](i);
        if (c == '\n') {
           if (has_text) {
             new_string += substr(indent_stop, i - indent_stop);
           }
           new_string += "\r\n"; // FIX - Use CRLF for the new line character
           has_text = false;
           line_start = i + 1;
           indent_stop = -1;
        } else if (!has_text) {
           if (c > 32) {
             has_text = true;
             if (!has_indent) {
                has_indent = true;
                indent = substr(line_start, i - line_start);
                indent_stop = i;
             }
           }
           if (has_indent && indent_stop < 0) {
             int j = i - line_start;
             if (j >= indent.length() || c != indent[j]) {
                indent_stop = i;
             }
           }
        }
    }

    if (has_text) {
        new_string += substr(indent_stop, length() - indent_stop);
    }

    return new_string;
}
```

-----

### `editor\import\3d\resource_importer_scene.cpp`

**At Line 3304:**

```cpp
   if (post_import_script.is_valid()) {
      post_import_script->init(p_source_file);
      scene = post_import_script->post_import(scene);
      if (!scene) {
         EditorNode::add_io_error(
                 TTR("Error running post-import script:") + " " + post_import_script_path + "\r\n" + // FIX - Use CRLF for error message
                 //change to \n if crash
                 TTR("Did you return a Node-derived object in the `_post_import()` method?"));
         return err;
      }
   }
```

-----

### `modules\gdscript\gdscript_parser.cpp`

**At Line 365:**

```cpp
   // FIX - Handle both CRLF and LF:
   String normalized_source = p_source_code.replace("\r\n", "\n");
   const Vector<String> lines = normalized_source.split("\n");
```

**At Line 5585:**

```cpp
void GDScriptParser::TreePrinter::push_line(const String &p_line) {
    if (!p_line.is_empty()) {
        push_text(p_line);
    }
    printed += "\r\n"; // FIX - Use CRLF for output
    pending_indent = true;
}
```

**At Line 3832:**

```cpp
   String line_join;
   if (!p_text.is_empty()) {
      if (r_state == DOC_LINE_NORMAL) {
         if (p_text.ends_with("[/codeblock]")) {
         #ifdef WINDOWS_ENABLED
            line_join = "\r\n"; //for windows
         #else
            line_join = "\n";
         #endif
         } else if (!p_text.ends_with("[br]")) {
            line_join = " ";
         }
      } else {
      #ifdef WINDOWS_ENABLED
         line_join = "\r\n";
      #else
         line_join = "\n";
      #endif
      }
   }
```

**At Line 3878:**

```cpp
          if (lb_pos == 0) {
                 // line_join = "\n";
               //#custom
                   #ifdef WINDOWS_ENABLED
                      line_join = "\r\n";
                   #else
                      line_join = "\n";
                   #endif
                } else {
                   #ifdef WINDOWS_ENABLED
                      result += line.substr(buffer_start, lb_pos - buffer_start) + "\r\n";
                   #else
                      result += line.substr(buffer_start, lb_pos - buffer_start) + '\n';
                   #endif
                }
                result += "[" + tag + "]";
                if (from < len) {
                   #ifdef WINDOWS_ENABLED
                      result += "\r\n";
                   #else
                      result += '\n';
                   #endif
                }
```

-----

### `editor\script\script_editor_plugin.cpp`

**At Line 4696:**

```cpp
// return String("\n").join(message);
           #ifdef WINDOWS_ENABLED
                   return String("\r\n").join(message);
           #else
                   return String("\n").join(message);
           #endif
```

**At Line 4714:**

```cpp
//return String("\n").join(message);
   #ifdef WINDOWS_ENABLED
     return String("\r\n").join(message);
   #else
     return String("\n").join(message);
   #endif
```

-----

### `editor\script\script_create_dialog.cpp`

**At Line 816:**

```cpp
// script_template.content += line.substr(i) + "\n";
            // FIX:
            #ifdef WINDOWS_ENABLED
               script_template.content += line.substr(i) + "\r\n";
            #else
               script_template.content += line.substr(i) + "\n";
            #endif
```

**At Line 827:**

```cpp
// script_template.content = script_template.content.lstrip("\n");
   // FIX:
   #ifdef WINDOWS_ENABLED
     script_template.content = script_template.content.lstrip("\r\n").lstrip("\n");
   #else
     script_template.content = script_template.content.lstrip("\n");
   #endif
```

-----

### Errors

Due to these edits, a visible issue has appeared:

```pwsh
Set exec_path
Set exec_path
Create Node
Attach Script
 ERROR: Could not create child process: "C:\Users\<username>\AppData\Local\Programs\Microsoft VS Code\bin\code" "D:/5. ComputerScience/GameProjects/new-game-project" --goto "D:/5.ComputerScience/GameProjects/new-game-project/sprite_2d_2.gd:1:1"
 ERROR: editor\script\script_editor_plugin.cpp:2609 - Couldn't open external text editor, falling back to the internal editor. Review your `text_editor/external/` editor settings.
```

### Attempted Fix

In `editor\script\script_editor_plugin.cpp` at **line 2602 - 2627**, I attempted to fix the issue by changing the `create_process` call to include quoting for the paths:

**Original (commented out):**

```cpp
// if (!path.is_empty()) {
//    Error err = OS::get_singleton()->create_process(path, args);
//    if (err == OK) {
//       return false;
//    }
// }
```

**New code:**

```cpp

		String quoted_path = path;
		List<String> quoted_args;

		for (const String &arg : args) {
			if (arg.find(" ") != -1) {
				quoted_args.push_back("\"" + arg + "\"");
			} else {
				quoted_args.push_back(arg);
			}
		}

		Error err = OS::get_singleton()->create_process(quoted_path, quoted_args);


```

### `misc\scripts\gitignore_check.sh`

**Replaced the contents with what is below**
 [Else GHA fails]
```bash
# set -uo pipefail
# shopt -s globstar

# echo -e ".gitignore validation..."

# # Get a list of files that exist in the repo but are ignored.

# # The --verbose flag also includes files un-ignored via ! prefixes.
# # We filter those out with a somewhat awkward `awk` directive.
# 	# (Explanation: Split each line by : delimiters,
# 	# see if the actual gitignore line shown in the third field starts with !,
# 	# if it doesn't, print it.)

# # ignorecase for the sake of Windows users.

# output=$(git -c core.ignorecase=true check-ignore --verbose --no-index **/* | \
#     awk -F ':' '{ if ($3 !~ /^!/) print $0 }')

# # Then we take this result and return success if it's empty.
# if [ -z "$output" ]; then
#     exit 0
# else
# 	# And print the result if it isn't.
#     echo "$output"
#     exit 1
# fi
#!/bin/bash

# Exit on any error, undefined variables, and pipe failures
set -euo pipefail

# Enable globstar for ** patterns (bash 4.0+)
shopt -s globstar

echo ".gitignore validation..."

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not inside a git repository"
        exit 1
    fi
}

# Function to validate .gitignore
validate_gitignore() {
    echo "Checking for files that should be ignored but are tracked..."

    # Get all tracked files that should be ignored
    # Using git ls-files to get tracked files, then check each against .gitignore
    local ignored_but_tracked=""

    while IFS= read -r file; do
        # Check if this tracked file would be ignored by .gitignore
        if git check-ignore "$file" >/dev/null 2>&1; then
            ignored_but_tracked="$ignored_but_tracked$file"$'\n'
        fi
    done < <(git ls-files)

    # Also check for files that exist but are improperly ignored
    echo "Checking for files that exist in repo but are ignored..."

    # Get a list of files that exist in the repo but are ignored
    # The --verbose flag shows which .gitignore rule matched
    # Filter out un-ignored files (those with ! prefix)
    local improperly_ignored
    improperly_ignored=$(git -c core.ignorecase=true check-ignore --verbose --no-index ./**/* 2>/dev/null | \
        awk -F ':' '{
            # Skip files that are un-ignored (start with !)
            if ($3 !~ /^[[:space:]]*!/) {
                # Only show files that actually exist
                if (system("test -e \"" $4 "\"") == 0) {
                    print $4 " (ignored by: " $3 ")"
                }
            }
        }' || true)

    # Report results
    local has_errors=false

    if [ -n "$ignored_but_tracked" ]; then
        echo "ERROR: The following tracked files should be ignored:"
        echo "$ignored_but_tracked"
        has_errors=true
    fi

    if [ -n "$improperly_ignored" ]; then
        echo "WARNING: The following files exist but are ignored:"
        echo "$improperly_ignored"
        # Uncomment the next line if you want warnings to be treated as errors
        # has_errors=true
    fi

    if [ "$has_errors" = true ]; then
        echo "❌ .gitignore validation failed"
        exit 1
    else
        echo "✅ .gitignore validation passed"
        exit 0
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [--help] [--fix]"
    echo ""
    echo "Options:"
    echo "  --help    Show this help message"
    echo "  --fix     Attempt to fix issues by untracking ignored files"
    echo ""
    echo "This script validates that:"
    echo "  1. No tracked files should be ignored"
    echo "  2. No important files are accidentally ignored"
}

# Function to fix issues
fix_issues() {
    echo "Attempting to fix .gitignore issues..."

    # Untrack files that should be ignored
    while IFS= read -r file; do
        if git check-ignore "$file" >/dev/null 2>&1; then
            echo "Untracking ignored file: $file"
            git rm --cached "$file" 2>/dev/null || true
        fi
    done < <(git ls-files)

    echo "Fixed! Please review changes and commit if appropriate."
}

# Main execution
main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --fix)
            check_git_repo
            fix_issues
            ;;
        "")
            check_git_repo
            validate_gitignore
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"

```






#!/bin/bash
# Copyright 2016 Matthias Neugebauer All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

FILE="main"
BIBTEX="false"
GLOSSARIES="false"
IGNORE_ERRORS="false"
WATCH="false"
TEXMF="false"
TEXMF_PATH=""
INIT="false"
INIT_FILE=""

printUsage() {
  echo "Usage: build.sh [OPTIONS]"
  echo
  echo "Options:"
  echo
  echo "  -f, --file [FILE]     Name of the tex file without file ending (default: 'main')"
  echo "  -b, --bibtex          Run bibtex"
  echo "  -g, --glossaries      Run makeglossaries"
  echo "  -w, --watch           Watch for changes"
  echo "      --ignore-errors   Continue watching even if an error occurred"  
  echo "  -t, --texmf [PATH]    Custom texmf folder path"
  echo "  -i, --init [FILE]     Name of the font to be initialized"
  echo "  -h, --help            Print usage"
}

runPdflatex() {
  if [[ "${TEXMF}" == "true" ]]; \
  then TEXMFHOME="${TEXMF_PATH}" \
  pdflatex \
    -interaction nonstopmode \
    -file-line-error \
    -synctex 1 \
    "${FILE}.tex"; \
  else \
    pdflatex \
      -interaction nonstopmode \
      -file-line-error \
      -synctex 1 \
      "${FILE}.tex"; fi;
}

runMakeglossaries() {
  for f in ./*.{glo,acn}; do
    makeglossaries -q "$f"
  done
}

runBibtex() {
  if [[ "${TEXMF}" == "true" ]]; \
   then TEXMFHOME="${TEXMF_PATH}" bibtex -terse "${FILE}.aux"; \
   else bibtex -terse "${FILE}.aux"; fi;
}

initTexmf(){
  if [[ "${TEXMF}" == "true" ]]; \
  then TEXMFHOME="${TEXMF_PATH}" mktexlsr \
  && TEXMFHOME="${TEXMF_PATH}" updmap --enable Map "${INIT_FILE}";\
  else mtexlsr \
  && updmap --enable Map "${INIT_FILE}"; fi;\
}

run() {
  {
    if [[ "${INIT}" == "true" ]]; then initTexmf; fi \
    && runPdflatex \
    && runPdflatex \
    && if [[     "${BIBTEX}" == "true" ]]; then runBibtex; fi \
    && if [[ "${GLOSSARIES}" == "true" ]]; then runMakeglossaries; fi \
    && if [[ "${GLOSSARIES}" == "true" || \
                 "${BIBTEX}" == "true" ]]; then runPdflatex; runPdflatex; fi \
    && echo "BUILD SUCCEEDED"
  } \
  ||
  {
    >&2 echo "BUILD FAILED";
    return 1
  }
}

watch() {
  while true; do
    set +e
    if ! run && [[ "${IGNORE_ERRORS}" == "false" ]]; then exit 1; fi
    set -e

    inotifywait -rq \
      -e modify \
      -e move \
      -e create \
      -e delete \
      .
  done
}

main() {
  if [[ "${WATCH}" == "true" ]]; then
    watch
  else
    run
  fi
}

while [[ $# -gt 0 ]]; do
  opt="$1"

  case $opt in
    -f|--file)
      FILE="$2"
      shift
      ;;
    -b|--bibtex)
      BIBTEX="true"
      ;;
    -g|--glossaries)
      GLOSSARIES="true"
      ;;
    -w|--watch)
      WATCH="true"
      ;;
    --ignore-errors)
      IGNORE_ERRORS="true"
      ;;
    -t|--texmf)
      TEXMF="true"
      TEXMF_PATH="$2"
      shift
      ;;
    -i|--init)
      INIT="true"
      INIT_FILE="$2"
      shift
      ;;
    -h|--help)
      printUsage
      exit
      ;;
    *)
      >&2 echo "Unkown option '${opt}'"
      >&2 echo
      >&2 printUsage
      exit 1
      ;;
  esac
  shift
done

main

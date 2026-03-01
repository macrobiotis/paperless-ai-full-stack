#!/usr/bin/env bash

ollama serve &
sleep 10
ollama pull llama3.2
ollama pull qwen2.5:7b
tail -f /dev/null

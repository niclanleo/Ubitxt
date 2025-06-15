#!/bin/bash
cd ~/Documents/ObsidianVault/思維模型
git add .
git commit -m "自動更新 $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

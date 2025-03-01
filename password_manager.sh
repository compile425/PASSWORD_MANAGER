#! /bin/bash
while true; do
  echo "パスワードマネージャーへようこそ！"
  echo "GPGキーで設定したメールアドレスを入力してください。"
  read gpgEmail
  if [ -z "$gpgEmail" ]; then
    echo "GPGキーのメールアドレスが入力されていません。"
    continue
  fi
  echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
  read choice

  case $choice in
    "Add Password")
      while true; do
        read -p "サービス名を入力してください：" serviceName
        if [ -z "$serviceName" ]; then
          echo "サービス名が入力されていません。"
          continue
        fi
        if [ -f "passWords.gpg" ]; then
          gpg -d passWords.gpg > passWords.txt 2> /dev/null
          if grep -q "^$serviceName:" passWords.txt; then
            echo "そのサービスは既に登録されています。"
            rm passWords.txt
            continue
          fi
        fi
        break
      done

      read -p "ユーザー名を入力してください：" userName
      if [ -z "$userName" ]; then
        echo "ユーザー名が入力されていません。"
        continue
      fi
      read -p "パスワードを入力してください：" passWord
      if [ -z "$passWord" ]; then
        echo "パスワードが入力されていません。"
        continue
      fi
      if [ -f "passWords.gpg" ]; then
        gpg -d passWords.gpg > passWords.txt 2> /dev/null
      fi
      echo "$serviceName:$userName:$passWord" >> passWords.txt
      gpg -r "$gpgEmail" -e -o passWords.gpg passWords.txt
      echo "パスワードの追加は成功しました。"
      rm passWords.txt
      ;;
    "Get Password")
      read -p "サービス名を入力してください：" serviceName
      if [ -z "$serviceName" ]; then
        echo "サービス名が入力されていません。"
        continue
      fi
      gpg -d passWords.gpg > passWords.txt 2> /dev/null
      if [ -z "$passWord" ]; then
        echo "そのサービスは登録されていません。"
      else
      userName=$(grep "^$serviceName:" passWords.txt | cut -d: -f2)
      passWord=$(grep "^$serviceName:" passWords.txt | cut -d: -f3)
        echo "サービス名：$serviceName"
        echo "ユーザー名：$userName"
        echo "パスワード：$passWord"
      fi
      rm passWords.txt
      ;;
    "Exit")
      echo "Thank you!"
      exit
      ;;
    *)
      echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
      ;;
  esac
done

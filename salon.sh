#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n" 


MAIN_MENU(){
  while true; do
    if [[ $1 ]]
    then
      echo -e "\n$1"
    fi

    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
      do
      if [[ $SERVICE_ID != 'service_id' ]]
      then
        echo "$SERVICE_ID) $NAME"
      fi
      done

    read SERVICE_ID_SELECTED
    SERVICE_ID_CHECK=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_FORMATTED=$(echo $SERVICE_ID_CHECK | sed 's/ //g')

    if [[ -z $SERVICE_ID_CHECK ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      continue
    else
      break
    fi 
  done

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_CHECK=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_PHONE_CHECK ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_ID=$(echo $CUSTOMER_PHONE_CHECK | cut -d '|' -f 1 | sed 's/ //g')
    CUSTOMER_NAME=$(echo $CUSTOMER_PHONE_CHECK | cut -d '|' -f 2 | sed 's/ //g')
  fi

  echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

 MAIN_MENU

import json
import urllib
import base64
import argparse
import boto3
import pandas as pd
import requests as rq
import sys, traceback, os
from io import StringIO
from datetime import datetime
from geopy.geocoders import Nominatim

S3_PATH = "input/idealista/{country}/{city}/{operation}/{property_type}/{date}/{file_name}"
FILE_NAME = '{country}_{city}_{operation}_{property_type}_{date}.csv'

locale = 'pt'  # values: es, it, pt, en, ca
language = 'pt'
max_items = '50'
sort = 'desc'


def check_order(property_type, order_field):
    order_options = {
        'garages': ['distance', 'price', 'street', 'photos', 'publicationDate', 'modificationDate', 'weigh',
                    'priceDown'],
        'premises': ['distance', 'price', 'street', 'photos', 'publicationDate', 'modificationDate', 'size', 'floor',
                     'ratioeurm2', 'weigh', 'priceDown'],
        'offices': ['distance', 'price', 'street', 'photos', 'publicationDate', 'modificationDate', 'size', 'floor',
                    'ratioeurm2', 'weigh', 'priceDown'],
        'homes': ['distance', 'size', 'rooms', 'floor', 'ratioeurm2', 'price', 'street', 'photos', 'modificationDate',
                  'publicationDate', 'weigh', 'priceDown', 'preservationTypeAndPrice', 'privateAds'],
        'rooms': ['distance', 'price', 'street', 'photos', 'publicationDate', 'modificationDate, floor']}

    try:
        if order_field not in order_options.get(property_type):
            raise Exception("Order option not valid")
    except:
        raise Exception("Order option not valid")

    return order_field


def get_geloc(city, country):
    # calling the Nominatim tool
    loc = Nominatim(user_agent="GetLoc")

    # entering the location name
    country_options = {'es': 'Espanha',
                       'it': 'Itália',
                       'pt': 'Portugal'}

    address = '{city}, {country}'
    getLoc = loc.geocode(address.format(city=city, country=country_options.get(country)))

    loc = {"latitude": getLoc.latitude,
           "longitude": getLoc.longitude}

    print('Searching for: ' + getLoc.address)
    print('Geo Location: ' + str(loc))

    return loc


def get_oauth_token(apikey, secret):
    url = "https://api.idealista.com/oauth/token"

    apikey_secret = apikey + ':' + secret
    auth = str(base64.b64encode(bytes(apikey_secret, 'utf-8')))[2:][:-1]

    headers = {'Authorization': 'Basic ' + auth, 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'}

    params = urllib.parse.urlencode({'grant_type': 'client_credentials'})  # ,'scope':'read'
    content = rq.post(url, headers=headers, params=params)
    bearer_token = json.loads(content.text)['access_token']

    return bearer_token


def search_api(token, url):
    print('\nAPI Call: ' + url)
    headers = {'Content-Type': 'Content-Type: multipart/form-data;', 'Authorization': 'Bearer ' + token}
    content = rq.post(url, headers=headers)
    result = json.loads(content.text)
    if content.status_code == 200 :
        return result['elementList']
    else:
        raise Exception(result['message'])


def upload_to_s3(df: pd.DataFrame, s3_bucket:str, s3_path: str):
    """Uploads DataFrame to s3"""

    csv_buffer = StringIO()
    df.to_csv(csv_buffer, index=False)
    s3 = boto3.resource('s3')

    s3_object = s3.Object(s3_bucket, s3_path)

    if df.shape[0] == 0:
        raise Exception(f"Error: cannot upload empty dataframe '{s3_path}' to s3")
    print(f'Uploading {df.shape[0]} rows to s3://{s3_object.bucket_name}/{s3_path}...')
    s3_object.put(Body=csv_buffer.getvalue())
    print(f'Successfully uploaded {df.shape[0]} rows to s3://{s3_bucket}/{s3_path}')


if __name__ == '__main__':
    # Providing command-line arguments
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--city', required=True, help='City name')
    parser.add_argument('--pages', required=False, help='Max pages to retrieve (50 records per page)', default=1)
    parser.add_argument('--date', required=False, help='Date for execution (yyyy-MM-dd)',
                        default=datetime.now().strftime('%Y-%m-%d'))
    parser.add_argument('--distance', required=False, help='Max distance from city in meters (ratio)', default=5000)
    parser.add_argument('--country', required=False, help='Country to search in', default='pt',
                        choices=['es', 'it', 'pt'])
    parser.add_argument('--operation', required=False, help='Type of operation', default='sale',
                        choices=['sale', 'rent'])
    parser.add_argument('--property_type', required=False, help='Type of property', default='homes',
                        choices=['homes', 'offices', 'premises', 'garages', 'bedrooms'])
    parser.add_argument('--order_field', required=False, help='Order field by property type', default='priceDown')
    parser.add_argument('--s3_bucket', required=False, help='String for the S3 bucket name',
                        default='{PREFIX}-datalake-{ENVIRONMENT}'.format(PREFIX=os.getenv("PREFIX"),
                                                                        ENVIRONMENT=os.getenv("ENVIRONMENT")) )
    try:
        args = parser.parse_args()
        city = args.city
        pages = int(args.pages)

        secret = os.getenv("IDEALISTA_SECRET")
        apikey = os.getenv("IDEALISTA_API_KEY")
        # Generate token
        if (secret is not None) & (apikey is not None):
            token = get_oauth_token(apikey, secret)
        else:
            print("Idealista API Key and Secret is needed.")
            print(" export IDEALISTA_API_KEY='apikey' ")
            print(" export IDEALISTA_SECRET='secret' ")
            raise Exception(f"Idealista API Key and Secret needed.")

        if (city):

            args = parser.parse_args()
            s3_bucket = args.s3_bucket

            distance = int(args.distance)
            property_type = args.property_type
            order = check_order(property_type, args.order_field)
            date = args.date
            country = args.country
            operation = args.operation

            # Get geolacation from city name in county
            location = get_geloc(city, country)
            center = '{},{}'.format(location['latitude'], location['longitude'])

            df_concat = pd.DataFrame()
            for i in range(1, pages+1):
                url = ('https://api.idealista.com/3.5/{country}' +
                       '/search?operation={operation}' +
                       '&locale={locale}' +
                       '&maxItems={max_items}' +
                       '&order={order}' +
                       '&center={center}' +
                       '&distance={distance}' +
                       '&propertyType={property_type}' +
                       '&sort={sort}' +
                       '&language={language}' +
                       '&numPage={num_page}'
                       ).format(country=country,
                                operation=operation,
                                locale=locale,
                                max_items=max_items,
                                order=order,
                                center=center,
                                distance=distance,
                                property_type=property_type,
                                sort=sort,
                                language=language,
                                num_page=i)

                result = search_api(token, url)
                #result = {'url':[url]}

                df = pd.DataFrame.from_dict(result)
                df_concat = pd.concat([df_concat, df])

            file_name = FILE_NAME.format(country=country, city=city,
                                         operation=operation, property_type=property_type, date=date)
            s3_path = S3_PATH.format(country=country, city=city,
                                     operation=operation, property_type=property_type, date=date, file_name=file_name)

            print('Output data: ' + s3_path + '\n')
            upload_to_s3(df_concat, s3_bucket, s3_path)

    except:
        traceback.print_exc()
        sys.exit(1)

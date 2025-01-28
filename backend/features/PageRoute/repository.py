import csv
from features.PageRoute.model import QueryModel
from features.PageRoute.model import PagesModel
from core.constants.constants import Database_URI,DB_NAME,Collections

# Data Source Class
class PagesRepo:
    def __init__(self, file_name:str):

        self.csv_filename = file_name
        self.file=open(self.csv_filename,'r')

    def GetPagesCSV(self) -> PagesModel:

        reader = csv.reader(self.file)
        result=[]
        for row in reader:
            result.append(row)

        return PagesModel(result)


from pymongo import MongoClient
class QueriesRepo:
    def __init__(self):

        collection_name=Collections['storeQueries']

        self.client = MongoClient(Database_URI)
        self.db = self.client[DB_NAME]
        self.collection = self.db[collection_name]


    def StoreQueries(self , queries: QueryModel) -> list:

        Queries_data={
            'Queries':queries.query,
            'language':queries.language
        }

        try:
            result = self.collection.insert_one(Queries_data)
            queries.id = str(result.inserted_id)
            
        except Exception as e:
            raise ValueError(f"Database Error: {e}")

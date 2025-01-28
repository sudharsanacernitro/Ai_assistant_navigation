# app/schemas/user_schema.py
from pydantic import BaseModel

class QuerySchema(BaseModel):
    query: str
    language: str

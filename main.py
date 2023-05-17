from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
from decouple import config

app = FastAPI()

client = AsyncIOMotorClient(config("MONGO_URL"))
db = client[config("MONGO_DB")]

class User(BaseModel):
    id: str = None
    social_media_username: str
    active: bool = True

@app.get("/", response_model=List[User])
async def read_root():
    users = []
    async for user in db.users.find():
        user["id"] = str(user["_id"])
        del user["_id"]
        users.append(user)
    return users

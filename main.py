import sys
import traceback

import uvicorn

print("Starting...")

try:
    import time
    from typing import List

    from decouple import config
    from fastapi import FastAPI
    from motor.motor_asyncio import AsyncIOMotorClient
    from pydantic import BaseModel

    print("Modules imported successfully.")

    app = FastAPI()

    client = None
    while not client:
        try:
            client = AsyncIOMotorClient(config("MONGO_URL"))
        except Exception as e:
            print(f"Unable to connect to MongoDB. Error: {e}")
            print("Retrying in 5 seconds...")
            time.sleep(5)

    print("Connected to MongoDB.")

    db = client[config("MONGO_DB")]

    class User(BaseModel):
        id: str = None
        social_media_username: str
        active: bool = True

    @app.get("/", response_model=List[User])
    async def read_root():
        users = []
        if db:
            async for user in db.users.find():
                user["id"] = str(user["_id"])
                del user["_id"]
                users.append(user)
        return users

    print("FastAPI application setup complete.")

except Exception as e:
    print("An exception occurred:", e)
    traceback.print_exc(file=sys.stdout)

print("End of script.")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

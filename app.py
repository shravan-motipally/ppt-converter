import dotenv
import os

# Add fast api requirements
from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.datastructures import FormData, UploadFile
from src.extractor import PowerpointExtractor
from io import BytesIO

# Load the environment variables
dotenv.load_dotenv()

# create a fast api instance starting at the 80 port
app = FastAPI()


async def get_body(request: Request):
    content_type = request.headers.get("Content-Type")
    if content_type is None:
        raise HTTPException(status_code=400, detail="No Content-Type provided!")
    elif content_type == "application/x-www-form-urlencoded" or content_type.startswith(
        "multipart/form-data"
    ):
        try:
            print("Parsing form data...")
            print(f"Content-Type: {content_type}")
            print(f"request details: {request}")
            return await request.form()
        except Exception as e:
            print(f"Error parsing form data: {e}")
            raise HTTPException(status_code=400, detail="Invalid Form data")
    else:
        raise HTTPException(status_code=400, detail="Content-Type not supported!")


@app.post("/upload")
async def extract_powerpoint(body=Depends(get_body)):
    if isinstance(body, FormData):  # if Form/File data received
        for k in body:
            entries = body.getlist(k)
            if isinstance(
                entries[0], UploadFile
            ):  # check if it is an UploadFile object
                for file in entries:
                    file_content = await file.read()
                    pptx_extractor = PowerpointExtractor(BytesIO(file_content))
                    data = pptx_extractor.extract_images_and_text()
                    return data
            else:
                data = entries if len(entries) > 1 else entries[0]
                print(f"{k}={data}")

    return "OK"


# Create a function for health check
@app.get("/health")
def health():
    return {"status": "ok"}


# Run the fast app
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)

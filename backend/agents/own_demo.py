import subprocess
from swarm import Agent, Swarm
from openai import OpenAI

import os

# Set proxy environment variables (commented out if not needed)
# os.environ["http_proxy"] =  'socks5://127.0.0.1:9050'
# os.environ["https_proxy"] = 'socks5://127.0.0.1:9050'

GPU_server = True

# Define the function
def run_nmap(target: str):
    """Scans a network with Nmap. Returns a summary of open ports."""
    command = f"nmap -sS -p- {target}"
    result = subprocess.run(command, shell=True, capture_output=True, text=True).stdout
    return result

def call(user_name: str, called_once=False):
    """Make a mobile call and return the status code."""
   
    print(f"Calling {user_name}")
    return "Success"

def message(user_name: str, messaged_once=False):
    """Send a message and return the status code."""
    
    print(f"Sending message to {user_name}")
    return "Success"

ip = "10" if GPU_server else "localhost"

# Set up the model client
ollama_client = OpenAI(
    base_url=f"http://localhost:11434/v1",
    api_key="ollama"
)

# Define the agent
cybersecurity_agent = Agent(
    name="Assistant Agent",
    model="qwen2.5-coder:3b",
    instructions="""
    You are an agent who can call or message users only once.
    """,
    functions=[run_nmap, call, message],  
)

# Initialize the swarm client
client = Swarm(client=ollama_client)

# Message to trigger the agent
messages = [{"role": "user", "content": "Make a call to Ram"}]

# Run the agent with a flag to ensure the function is called only once
response = client.run(
    agent=cybersecurity_agent,
    messages=messages,
    context_variables={},  # Ensuring the function call only once
    stream=False,
)

# Output the result
print(response)

# import json
# from swarm.repl import run_demo_loop
# from swarm import Agent
# from openai import OpenAI
# from swarm import Swarm

# import subprocess

# # LLM and environment setup
# ollama_client = OpenAI(
#     base_url="http://localhost:11434/v1",        
#     api_key="ollama"            
# )

# from dotenv import load_dotenv
# import os

# load_dotenv()
# model = os.getenv('LLM_MODEL', 'qwen2.5-coder:3b')

# # Function definitions
# def run_nmap(target: str):
#     """Scans a network with Nmap. Returns a summary of open ports."""
#     command = f"nmap -sS -p- {target}"
#     result = subprocess.run(command, shell=True, capture_output=True, text=True).stdout
#     return result

# def get_weather(location, time="now"):
#     """Get the current weather in a given location. Location MUST be a city."""
#     return json.dumps({"location": location, "temperature": "65", "time": time})

# def send_email(recipient, subject, body):
#     print("Sending email...")
#     print(f"To: {recipient}")
#     print(f"Subject: {subject}")
#     print(f"Body: {body}")
#     return "Sent!"

# # Define the agent
# weather_agent = Agent(
#     name="Weather Agent",
#     instructions="You are a helpful cyber-security agent. Analyze tool outputs and provide concise summaries.",
#     functions=[get_weather, send_email, run_nmap],
#     model=model
# )

# # Define the swarm client
# client = Swarm(client=ollama_client)

# # Step 1: Execute Nmap and capture raw output
# target_ip = "127.0.0.1"
# nmap_output = run_nmap(target_ip)

# # Step 2: Use LLM to summarize Nmap output
# messages = [
#     {"role": "system", "content": "You are a helpful cybersecurity agent. Summarize tool outputs."},
#     {"role": "user", "content": f"The following is the output of an Nmap scan for target {target_ip}:\n{nmap_output}\nSummarize the key findings."}
# ]

# response = client.run(
#     agent=weather_agent,
#     messages=messages,  # Pass updated messages
#     context_variables={},
#     stream=False,
#     debug=False,
# )

# print(response)

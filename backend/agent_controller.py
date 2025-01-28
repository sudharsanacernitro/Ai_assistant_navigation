from swarm import Agent,Swarm
from openai import OpenAI

from agents import own_demo

ollama_client = OpenAI(
    base_url=f"http://localhost:11434/v1",
    api_key="ollama"
)

def get_sql_router_agent_instructions():
    return """You are an orchestrator of different agent experts and it is your job to
    determine which of the agent is best suited to handle the user's request, 
    and transfer the conversation to that agent."""



Main = Agent(
    name="Router Agent",
    model="qwen2.5-coder:3b",
    instructions=get_sql_router_agent_instructions()
)

def transfer_back_to_router_agent():
    """Call this function if a user is asking about data that is not handled by the current agent."""
    return Main

def transfer_to_rss_feeds_agent():
    return own_demo.cybersecurity_agent



Main.functions = [transfer_to_rss_feeds_agent,transfer_back_to_router_agent]
own_demo.cybersecurity_agent.functions.append(transfer_back_to_router_agent)

client = Swarm(client=ollama_client)

# Message to trigger the agent
messages = [{"role": "user", "content": "Make a phone-call to ram "}]

# Run the agent
response = client.run(
    agent=Main,  
    messages=messages,
    context_variables={},
    stream=False,
    
)

# Output the result
print(response)
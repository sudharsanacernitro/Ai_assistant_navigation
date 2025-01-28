from swarm import Agent,Swarm
from openai import OpenAI

import features.PageRoute.endpoint.logic.sematic as sematic


ollama_client = OpenAI(
    base_url=f"http://localhost:11434/v1",
    api_key="ollama"
)

client = Swarm(client=ollama_client)

def page_router_agent_info():
    return """Use "semantic_search function" to identify the page they want to achieve based on the query."""


def semantic_search(command :str):
    """
    Return the page they asking by understanding the query.

    Args:
      command: command given by the user to navigate.
    """

    print(sematic.identify_page_semantically(command=command))
   
router_agent = Agent(
    name="Router Agent",
    model="qwen2.5-coder:3b",
    instructions=page_router_agent_info(),
    functions=[semantic_search]
)


# Run the agent
response = client.run(
    agent=router_agent,  
    messages=[{"role": "user", "content": "want to take picture."}],
    context_variables={},
    stream=False,
    
)

# Output the result
print(response)
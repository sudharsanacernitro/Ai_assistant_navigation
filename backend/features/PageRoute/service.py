

# app/services/user_service.py
from features.PageRoute.model import QueryModel,PagesModel
from features.PageRoute.repository import PagesRepo,QueriesRepo
from features.PageRoute.schema import QuerySchema
         
class PagesService:
    def __init__(self):
        self.PageRepo_interface=PagesRepo('features/PageRoute/pages.csv')

    def GetPages(self):
        
        # Validate incoming data using Pydantic
        PageModel_interface=self.PageRepo_interface.GetPagesCSV()

        return(PageModel_interface)
        

class QueryService:
    def __init__(self):
            self.QueryRepo = QueriesRepo()

    def Store(self, user_data: dict,pages : PagesModel):
        
        # Validate incoming data using Pydantic
        validated_data = QuerySchema(**user_data)

        if validated_data.query==None:
            raise ValueError("No Queries found")

        # Create and save the user
        new_query = QueryModel(id=None, query=validated_data.query, language=validated_data.language,response=None)

        self.QueryRepo.StoreQueries(new_query)

        return new_query
    


from swarm import Agent, Swarm
from sentence_transformers import SentenceTransformer, util
from core.constants.constants import ollama_client

class AgentService:
    def __init__(self, pages:PagesModel):

        self.client = Swarm(client=ollama_client)
        self.pages = pages.data
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
        self.page_req = ""

        self.translateService=TranslateService()

    def page_router_agent_info(self):
        return """Use "semantic_search function" to identify the page they want to achieve based on the query."""


    def semantic_search(self,  command: str):
        """
        Return the page (as string) they are asking for by understanding the query.

        Args:
          command: Command given by the user to navigate.
        """
        self.page_req = self.identify_page_semantically(command=command)
        return self.page_req


    def identify_page_semantically(self, command: str) -> str:
        """Identify the page based on the semantic meaning of the command."""

        command_embedding = self.model.encode(command, convert_to_tensor=True)
        
        page_similarities = {}
        for page_name, description in self.pages.items():
            description_embedding = self.model.encode(description, convert_to_tensor=True)
            similarity = util.pytorch_cos_sim(command_embedding, description_embedding)
            page_similarities[page_name] = similarity.item()
        
        best_match = max(page_similarities, key=page_similarities.get)
        return best_match

    def run_agent(self, queryModel:QueryModel) -> QueryModel:

        self.page_req=""

        query=queryModel.query
        query=self.translateService.translate_to_english(query)

        
        router_agent = Agent(
            name="Router Agent",
            model="qwen2.5-coder:3b",
            instructions=self.page_router_agent_info(),
            functions=[self.semantic_search]
        )

        self.client.run(
            agent=router_agent,
            messages=[{"role": "system", "content": "Provide the result of the function"},
                      {"role": "user", "content": f"{query}"}],
            # context_variables=None,
            stream=False,
        )
        queryModel.response= self.page_req

        return queryModel


from deep_translator import GoogleTranslator

class TranslateService:
    
    def __init__(self):
        self.language= {
                        'hi_IN': 'hi',
                        'en_US': 'en',
                        'ta_IN':'ta'
                         }
        
    def translate_to_english(self,text):
        try:
            # Translate the text to English
            translation = GoogleTranslator(source='auto', target='en').translate(text)
            # Return the translated text
            print(translation)
            return translation
        except Exception as e:
            print(e)

    def english_to_other(self,lang, text):
        try:
            lan = self.language[lang]
            # Translate from English to the target language
            translation = GoogleTranslator(source='en', target=lan).translate(text)
            return translation
        except Exception as e:
            print(e)
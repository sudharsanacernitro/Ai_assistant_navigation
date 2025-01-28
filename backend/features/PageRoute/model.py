class PagesModel:
    def __init__(self,result_lst:list):
        self.data={}
        self.convert_data(result_lst)

    def convert_data(self, result):
        for screen_name, screen_description in result[1:]:  
            self.data[screen_name] = screen_description



class QueryModel:
    def __init__(self,id,query,language,response):
        self.id=id
        self.query=query
        self.language=language
        self.response=response

        
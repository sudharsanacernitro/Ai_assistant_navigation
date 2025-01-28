from flask import Blueprint, jsonify, request
from features.PageRoute.service import QueryService,PagesService,AgentService

user_bp = Blueprint('user_bp', __name__)



@user_bp.route('/change_page', methods=['POST'])
def add_user():

    data = request.json 

    pages_service=PagesService()
    Query_service =  QueryService()

    pages=pages_service.GetPages() #pages_interface.GetPages() -> Model

    result=Query_service.Store(user_data=data,pages=pages)


    if(result.id==None):
        #raise ValueError("Can't able to store the query")
        return jsonify({'msg':'Error'}),500
    
    Agent_service=AgentService(pages=pages)

    response=Agent_service.run_agent(result)

    print(response.response)
    
    return jsonify({'response':f'{response.response}','language':response.language}), 201



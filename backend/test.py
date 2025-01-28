from features.PageRoute.model import use_case

def funct():
    inst=use_case()
    data=inst.ret_data()
    print(data)

funct()
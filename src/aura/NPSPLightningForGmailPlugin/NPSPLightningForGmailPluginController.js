({
	handlePeopleChange: function(component, event, helper){
        var action = component.get("c.findAffiliatedAccountsByEmail");
        var pPeople = JSON.stringify(component.get('v.people'));
        var pMode = component.get('v.mode');
        pPeople = pPeople.replace('"from"', '"pFrom"');
        action.setParams({"people": pPeople,
                         "mode" : pMode});
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var retValue = response.getReturnValue();
                component.set("v.affiliations", retValue);
            } else{
                component.set('v.error', 'Uh oh error!');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    associateEmail: function(component, event, helper){
        var action = component.get("c.linkEmailToAccount");
        var pPeople = JSON.stringify(component.get('v.people'));
        pPeople = pPeople.replace('"from"', '"pFrom"');
        var accIdList = [];
        if(component.get('v.bulk')) {
            var accList = component.find('selectedAccounts');
            for(var i = 0; i < accList.length; i++) {
	            if(accList[i].get("v.checked"))    
                accIdList.push(accList[i].get("v.name"));
            }
        }
        else {
            accIdList.push(event.getSource().get("v.name"));
        }
        console.log(accIdList);
        action.setParams({"accIds": accIdList,
                         "subject" : component.get('v.subject'),
                          "message" : component.get('v.messageBody'),
                          "people" : pPeople });
        action.setCallback(this, function(response){
            var state = response.getState();
            var retValue = response.getReturnValue();
            if(state === "SUCCESS"){
                component.set("v.result", retValue);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The email was successfully recorded!",
                    "duration" : "500",
                    "type" : "dismissable",
                    "mode" : "pester"
                });
                toastEvent.fire();
            } else{
                component.set("v.result", retValue);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Naahhhhh!",
                    "message": "Crash and burn.",
                    "duration" : "2000"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})
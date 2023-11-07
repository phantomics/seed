window.seedData = {  };
window.seedElements = {  };
function fetchContact(system, branch, input, handler) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST',
                                body : JSON.stringify({ portal : system,
                                                        branch : branch,
                                                        input : input
                                                      }),
                                headers : { 'Content-type' : 'application/json; charset=UTF-8' }
                              }).then(function (response) {
        return response.json();
    }).then(function (data) {
        console.log('dt', data, data.oobReload);
        if (data.oobReload) {
            data.oobReload.forEach(function (item) {
                console.log('it', item);
                return htmx.trigger(seedElements[item], 'reload');
            });
        };
        return data;
    }).then(handler);
};
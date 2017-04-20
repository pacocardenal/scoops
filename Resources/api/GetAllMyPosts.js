
module.exports = {
    "get": function (req, res, next) {
        if (typeof req.params.length < 0) {
            console.log("error en la lista de parametros");
        }
        var query = { sql : "SELECT * FROM Posts" };
        
        req.azureMobile.data.execute(query)
            .then(function(results){
               res.json(results); 
            });
    }
}

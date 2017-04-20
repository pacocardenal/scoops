
module.exports = {
    "PUT": function (req, res, next) {
        var estado = req.query.estado;
        var item = req.query.id;
        var query = { sql : "UPDATE SET status = @status WHERE id = @id", parameters: [{status: estado, id: item}] };
        
        req.azureMobile.data.execute(query)
            .then(function(result){
                res.json(result);
            });
    }
};

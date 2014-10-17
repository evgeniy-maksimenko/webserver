define([
	'backbone',
	 
],function(Backbone){
	var Model = Backbone.Model.extend({
		url: "/api/users?condition=add_user",
	});

	return Model;
})


define([

	'backbone',

],function(Backbone){	
	
	var ItemPage = Backbone.View.extend({
		render: function(){
            console.log(this.model.toJSON());
            this.$el.html();

            return this;
        },
        
	});

	return ItemPage;
	
});
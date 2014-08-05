define([

], function() {
	'use strict';

	requirejs.config({
		paths: {
			'jquery' 		: 'libs/jquery/jquery-1.11.1.min',
			'underscore' 	: 'libs/underscore/underscore',
			'backbone' 		: 'libs/backbone/backbone',

			'router' 		: 'libs/rjs/rjs-router',
			'text' 			: 'libs/rjs/rjs-text'
		},

		shim: {
			'backbone' : {
				deps 	: ['jquery', 'underscore'],
				exports : 'Backbone'
			}
		}
	});

	requirejs([
		'jquery',
		'router'
	], function($, router) {
		var view;

		router.registerRoutes({
			home 		: { path: '/', moduleId: 'views/home'},
			notFound 	: { path: '*', moduleId: 'views/notFound'}
		}).on('routeload', function onRouteLoad(View, routeArguments) {
			if(view) {
				view.remove();
			}
			view = new View(null, routeArguments);
			view.render();
			$('body').append(view.el);
		}).init();
	});
});


















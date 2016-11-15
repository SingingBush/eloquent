module eloquent.config.context;

import hibernated.session;
import poodinis;
import vibe.core.log; // only the logger is needed

import eloquent.config.properties, eloquent.config.database, eloquent.config.logging, eloquent.config.motd;
import eloquent.controllers;
import eloquent.services;

class PoodinisContext : ApplicationContext {

    private Properties _properties;

    public this() {
    	displayBanner();
    }

    public override void registerDependencies(shared(DependencyContainer) container) {
        Properties properties = new Properties;
        configureLogging(properties);
        logInfo("Registering Dependencies with Poodinis Context");
        container.register!Properties.existingInstance(properties);

		container.register!(EloquentDatabase, EloquentDatabaseImpl);
        EloquentDatabase dbConfig = container.resolve!EloquentDatabase;
        SessionFactoryImpl sessionFactory = dbConfig.configure();
        container.register!(SessionFactory, SessionFactoryImpl)(RegistrationOption.doNotAddConcreteTypeRegistration).existingInstance(sessionFactory);
        container.register!(UserService, UserServiceImpl)(RegistrationOption.doNotAddConcreteTypeRegistration);
        container.register!(BlogService, BlogServiceImpl)(RegistrationOption.doNotAddConcreteTypeRegistration);

		// register Controllers (used as vibe-d WebInterface)
        container.register!WebappController;
        container.register!AdminController;
    }

//	@Component
//	public SessionFactory createSessionFactory() {
//		EloquentDatabase dbConfig = new EloquentDatabase;
//        return dbConfig.configure();
//	}
}


module eloquent.config.context;

import hibernated.session;
import poodinis;
import vibe.core.log; // only the logger is needed

import eloquent.config.properties, eloquent.config.database, eloquent.config.logging;
import eloquent.controllers.web, eloquent.controllers.admin;
import eloquent.services.userservice, eloquent.services.blogservice;

class PoodinisContext : ApplicationContext {

    private Properties _properties;

    public this() {
    	logInfo("Creating Poodinis Context");
        _properties = new Properties;
        configureLogging(_properties);
    }

    public override void registerDependencies(shared(DependencyContainer) container) {
        logInfo("Registering Dependencies");
        container.register!Properties.existingInstance(_properties);

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


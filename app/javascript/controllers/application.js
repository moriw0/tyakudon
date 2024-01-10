import { Application } from "@hotwired/stimulus";

const application = Application.start();

// Configure Stimulus development experience
application.debug = true;
application.debug = process.env.NODE_ENV === "development";

export { application };

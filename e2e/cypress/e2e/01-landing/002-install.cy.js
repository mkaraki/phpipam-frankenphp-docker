describe('Perform initial configuration', () => {
    it('Perform automatic database installation', () => {
        cy.visit('/');
        
        // Click
        cy.contains('New phpipam installation').click();

        // Check URL
        cy.url().should('include', 'index.php?page=install&section=select_type');

        // Click
        cy.contains('Automatic database installation').click();

        // Check URL
        cy.url().should('include', 'index.php?page=install&section=install_automatic');

        // Input database information to form
        cy.get('input[name="mysqlrootuser"]').type('root');
        cy.get('input[name="mysqlrootpass"]').type('toor');
        // Following 2 fields are customized in config.php and disabled.
        //cy.get('input[name="mysqllocation"]').type('mariadb'); // Already customized in config.php
        //cy.get('input[name="mysqltable"]').type('phpipam'); // Default
        
        // Click 'Show advanced options' to disable 'Set permissions to tables' checkbox
        cy.contains('Show advanced options').click();
        cy.get('input[name="creategrants"]').uncheck();

        // Click 'Install phpipam database' button
        cy.contains('Install phpipam database').click();

        // Wait up to 120 seconds for `Database installed successfully!` dialog and `Continue` button.
        cy.contains('Database installed successfully!', { timeout: 120000 }).should('be.visible');
        cy.contains('Continue').click();

        // Check URL
        cy.url().should('include', '/index.php?page=install&section=install_automatic&subnetId=configure');

        // Configure
        cy.get('input[name="password1"]').type('Passw0rd');
        cy.get('input[name="password2"]').type('Passw0rd');
        cy.get('input[name="siteTitle"]').type('E2E Corp. IPAM');
        cy.get('input[name="siteURL"]').type('http://localhost:8080');

        // Click `Save settings` button
        cy.contains('Save settings').click();

        // Check URL
        cy.url().should('include', '/index.php?page=install&section=install_automatic&subnetId=success');

        // Check `Settings updated, installation complete!` message and click `Proceed to login.` button
        cy.contains('Settings updated, installation complete!').should('be.visible');
        cy.contains('Proceed to login.').click();

        // Check URL
        cy.url().should('include', '/index.php?page=login');
    });

    it('Login and Logout', () => {
        cy.visit('/');
        cy.url().should('include', '/index.php?page=login');

        // Input username and password
        cy.get('input[name="ipamusername"]').type('admin');
        cy.get('input[name="ipampassword"]').type('Passw0rd');

        // Click `Login` input['type="submit"]` button
        cy.get('input.btn-success[type="submit"]').click();

        // Wait URL becomes `/` up to 10 seconds
        cy.url({ timeout: 10000 }).should('eq', `${Cypress.config().baseUrl}/`);

        // Click `Logout` button
        cy.contains('Logout').click();

        // Check URL
        cy.url().should('include', '/index.php?page=login');

        // Check `You have logged out` message
        cy.contains('You have logged out').should('be.visible');
    });
});


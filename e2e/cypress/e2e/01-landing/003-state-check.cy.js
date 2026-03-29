describe('Configuration check', () => {
    beforeEach(() => {
        cy.visit('/index.php?page=login');

        // Input username and password
        cy.get('input[name="ipamusername"]').type('admin');
        cy.get('input[name="ipampassword"]').type('Passw0rd');

        // Click `Login` input['type="submit"]` button
        cy.get('input.btn-success[type="submit"]').click();

        // Wait URL becomes `/` up to 10 seconds
        cy.url({ timeout: 10000 }).should('eq', `${Cypress.config().baseUrl}/`);
    });

    afterEach(() => {
        // Click `Logout` button
        cy.contains('Logout').click();

        // Check URL
        //cy.url().should('include', '/index.php?page=login');

        // Check `You have logged out` message
        cy.contains('You have logged out').should('be.visible');
    });

    it('Check Ping path is not error', () => {
        cy.visit('/index.php?page=administration&section=settings');

        // Check Ping 
        cy.get('input[name="scanPingPath"]').parent().should('not.have.class', 'danger');
    });

    it('Check FPing path is not error', () => {
        cy.visit('/index.php?page=administration&section=settings');

        // Check Fping
        cy.get('input[name="scanFPingPath"]').parent().should('not.have.class', 'danger');
    });

    it('Check SNMP can enable', () => {
        cy.visit('/index.php?page=administration&section=settings');

        // Check Fping
        cy.get('input[name="enableSNMP"]').check({ force: true });

        // Save settings
        cy.contains('Save').click();

        // Error message: `Missing snmp support in php`

        // Check configuration finished
        cy.contains('Settings updated successfully').should('be.visible');
    });
});





















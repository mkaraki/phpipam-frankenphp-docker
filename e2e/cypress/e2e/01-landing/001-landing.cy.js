describe('Check installation wizard is working', () => {
    it('check "Welcome to phpipam installation wizard"', () => {
        cy.visit('/')
        cy.url().should('include', '/index.php?page=install')
        cy.get('h3').should('contain', 'Welcome to phpipam installation wizard!')
    });
});

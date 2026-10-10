# Continue the dashboard from either laptop

The GitHub repository stores the SQL and documentation. One GitHub Codespace runs the synthetic MySQL database and Metabase. Open **the same Codespace** on either laptop; Metabase questions and dashboards are saved in its MySQL application database. The database volume survives a normal Codespace stop and restart.

## Start once

1. Open the repository on GitHub. Select **Code → Codespaces → Create codespace on main**. Wait for the browser editor and the three containers to start. Pulling Metabase may take several minutes.
2. In the editor's **Ports** tab, open port **3000**. Keep its visibility **Private**. Complete Metabase's first-run admin setup using your own login. Do not use a work-only email that you cannot access at home.
3. When asked to add a database, select **MySQL** and enter:
   - Display name: `Financial Customer Demo`
   - Host: `mysql`; Port: `3306`
   - Database: `financial_customer_demo`
   - Username: `demo_reader`; Password: `synthetic-demo-reader`
4. Metabase should discover `users_customuser`, `plans_plan`, and `savings_savingsaccount`. Create saved SQL questions using the root `.sql` files and the card order in [METABASE_GUIDE.md](METABASE_GUIDE.md). Label the dashboard **Synthetic demo data**.

## Leave work; resume at home

1. Save each question and the dashboard in Metabase. In the Codespace editor, commit and push any changed SQL or documentation to GitHub (`Source Control → Commit → Sync Changes`).
2. On the personal laptop sign in to the **same GitHub account** and open [your Codespaces](https://github.com/codespaces). Resume the existing Codespace, then open private port 3000 from its Ports tab. Do not create a second Codespace.

The Codespace can stop when idle; restart it from the Codespaces page. GitHub may automatically delete an unused Codespace according to your account settings; deleting it also removes its MySQL volume and saved Metabase dashboard. For a durable backup, export the dashboard's questions and settings or keep your SQL and screenshots in the repository. Do not put personal or employer customer data in this demo. These committed passwords are for synthetic data in a private demo Codespace only.

If Metabase is still starting, wait and reopen port 3000. In the Codespace terminal, `docker compose -f .devcontainer/docker-compose.yml ps` shows the services. If the initial schema import fails, inspect `docker compose -f .devcontainer/docker-compose.yml logs mysql`; avoid deleting the `mysql_data` volume after saving dashboard work.

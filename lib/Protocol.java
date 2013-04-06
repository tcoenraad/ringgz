package protocol;
/**
 * P2 Eindopdracht 'Ringgz' 2013 
 * Interface Protocol met daarin de gemaakte afspraken tijdens werkcollege 13-3-2013
 * @author  Remco Tjeerdsma
 * @version 1.3.1 (28-3-2013)
 * 
 * Changelog:
 * CHAT_JOIN en CHAT_LEAVE zijn samengevoegd in CHAT_LIST, er wordt een lijst met alle aanwezige chatters verzonden naar clients.
 * CHALLENGE_JOIN en CHALLENGE_LEAVE zijn ook samengevoegd, in CHALLENGE_LIST, ook hier wordt een lijst met challengable players verzonden.
 * NOTIFY is aangepast, heeft een extra parameter 'naam' gekregen, om door te geven wie de zet heeft gedaan.
 * CHAT heeft nieuw argument 'name' met daarin naam van afzender van bericht, vrij essentieël :)
 * 
 * 
 * Vragen of opmerkingen? 
 * Er is een topic in het groepsforum op Blackboard.
 */


public interface Protocol {
	
	/*
	 * LET OP: VOLGORDE VAN PARAMETERS BIJ FUNCTIES IS EXPLICIET. VOLG VOLGORDE ZOALS IN JAVADOC AANGEGEVEN.
	 * 
	 * De volgorde van kleuren bij verschillende speler-modi is als volgt:
	 * 2 spelers: [0, 1] en [2, 3]
	 * 3 spelers: [0], [1], [2] en neutraal is [4]
	 * 4 spelers: [0], [1], [2] en [4]
	 * 
	 * In dit document worden de locaties van objecten gemarkeerd in een String met format "XY"
	 *   0  1  2  3  4   X
	 * 0 o--o--o--o--o
	 *   |  |  |  |  | 
	 * 1 o--o--o--o--o
	 *   |  |  |  |  | 			Voorbeeld: q = 23
	 * 2 o--o--o--o--o
	 *   |  |  |  |  | 
	 * 3 o--o--q--o--o
	 *   |  |  |  |  | 
	 * 4 o--o--o--o--o
	 * 
	 * Y   
	 */

	/* Definitie van de kleuren en bijbehorende nummers.
	 */
	int RED = 0;
	int BLUE = 1;
	int YELLOW = 2;
	int GREEN = 3;
	int EMPTY = 5;
	
	/* Definitie van de types en bijbehorende nummers.
	 */

	int SOLID = 0;
	int RING_XS = 1;
	int RING_S = 2;
	int RING_M = 3;
	int RING_L = 4;
	
	/* Wordt gebruikt om de client in te loggen op de server.
	 * @param name = Naam van deze client
	 * @param chat = Ondersteunt deze client chatfunctionaliteit?
	 * @param challenge = Ondersteunt deze client challengefunctionaliteit?
	 * 
	 * @require name bevat geen spaties
	 * @require chat = 1 || 0
	 * @require challenge = 1 || 0
	 * 
	 * Richting: Client -> Server
	 */
	String CLIENT_GREET = "greet";
	
	/* Wordt gebruikt om vanuit de server aan de client te melden welke functionaliteit ondersteund wordt.
	 * @param chat = Ondersteunt deze server chat-functionaliteit?
	 * @param challenge = Ondersteunt deze server challenge-functionaliteit?
	 * 
	 * @require chat = 1 || 0
	 * @require challenge = 1 || 0
	 * 
	 * Richting: Server -> Client
	 */
	String SERVER_GREET = "greet";
	
	/* Wordt gebruikt om aan de server duidelijk te maken dat men deel wil nemen aan een spel.
	 * Richting: Client -> Server
	 * @param amount = Aantal spelers in spel waaraan deelgenomen wordt.
	 * 
	 * @require 2 =< amount <= 4
	 */
	String JOIN = "join";
	
	/* Wordt gebruikt om aan clients duidelijk te maken dat een spel gestart wordt.
	 * Richting: Server -> Client
	 * @param names = Lijst met namen van deelnemers, gesorteerd op beurtvolgorde, gescheiden met een spatie.
	 * @param startlocation = Locatie van de startsteen.
	 * 
	 * @require startlocation = 11 || 12 || 13 || 21 || 22 || 23 || 31 || 32 || 33
	 */
	String START = "start";
	
	/* Wordt gebruikt om clients te vertellen dat ze een zet moeten doen.
	 * Richting: Server -> Client
	 */
	String SERVER_PLACE = "place";
	
	/* Wordt gebruikt om server mede te delen welke zet gedaan wordt.
	 * Richting: Client -> Server
	 * @param location = Locatie van de gedane zet.
	 * @param type = Soort ring of steen die geplaatst wordt.
	 * @param kleur = Kleur van geplaatste ring of steen.
	 * 
	 * @require kleur = RED || BLUE || YELLOW || GREEN
	 * @require type = SOLID || RING_XS || RING_S || RING_M || RING_L
	 * @require location = 00 || 01  || 02 || 03 || 04 || 10 || 11 || 12 || 13 || 14 || 20 || 21 || 22 || 23 || 24 || 30 || 31 || 32 || 33 || 34 || 40 || 41 || 42 || 43 || 44
	 */
	String CLIENT_PLACE = "place";
	
	 /* Wordt gebruikt om clients mede te delen welke zet gedaan werd.
		 * Richting: Server -> Client
	     * @param naam = Naam van de speler die de zet heeft gedaan
		 * @param location = Locatie van de gedane zet.
		 * @param type = Soort ring of steen die geplaatst wordt.
		 * @param kleur = Kleur van geplaatste ring of steen.
		 * 
	     * @require naam = naam van speler in spel
		 * @require kleur = RED || BLUE || YELLOW || GREEN
		 * @require type = SOLID || RING_XS || RING_S || RING_M || RING_L
		 * @require location = 00 || 01  || 02 || 03 || 04 || 10 || 11 || 12 || 13 || 14 || 20 || 21 || 22 || 23 || 24 || 30 || 31 || 32 || 33 || 34 || 40 || 41 || 42 || 43 || 44
		 */	
	String NOTIFY = "notify";
	
	/* Wordt gebruikt om clients de uitslag van het spel mede te delen.
	 * Richting: Server -> Client
	 * @param name = 	Naam van winnaar of
	 * 					Namen van gelijkspel-winnaars gescheiden door spatie of 
	 * 					Leeg als het spel afgesloten wordt zonder winnaar.
	 */
	String WINNER = "winner";
	
	/* Wordt gebruikt om informatie te verschaffen over een fout die zich heeft voorgedaan.
	 * Richting: Server -> Client && Client -> Server
	 * @param message = Foutmelding die door mensen te lezen is.
	 * @ensure WINNER zonder inhoud aangeroepen
	 */
	String ERROR = "error";
	
	
	/* ---------------------------EXTRA Functionaliteit ---------------------------	 */
	
	/* Wordt gebruikt om een chatbericht te verzenden.
	 * Richting: Client -> Server & Server -> Client
	 * @param name = String met afzender.
	 * @param message = String met chatbericht.
	 */
	String CHAT = "chat";
	
	
	/* Wordt gebruikt om een client te informeren van alle chatters in huidige chatbox.
	 * Richting: Server -> Client
	 * @param name = Lijst van namen in chatbox
	 */
	String CHAT_LIST = "chat_list";
	
	/* Wordt gebruikt om een lijst van challegable clients aan client te geven.
	 * Richting: Server -> Client
	 * @param name = Lijst van challengable clients
	 */
	String CHALLENGE_LIST = "challenge_list";
	
		
	/* Wordt gebruikt om de server te informeren over een gevraagde challenge.
	 * Richting: Client -> Server
	 * @param name = Lijst met namen van andere clients die gechallenged moeten worden.
	 * @require 1 <= aantal namen <= 3
	 */
	String CLIENT_CHALLENGE = "challenge";
	
	/* Wordt gebruikt om een client te informeren van een challenge.
	 * Richting: Server -> Client
	 * @param name = Lijst met namen van andere clients in zelfde challenge waarbij de uitdager vooraan staat.
	 * @require 1 <= aantal namen <= 3
	 */
	String SERVER_CHALLENGE = "challenge";
	
	/* Wordt gebruikt om een client te informeren van een challenge.
	 * Wordt ook gebruikt door uitdager (starter van challenge) om de challenge te annuleren.
	 * Richting: Client -> Server
	 * @param response = 	0 als client niet mee wenst te doen aan challenge
	 * 						1 als client wel mee wil doen aan challenge
	 * @require response = 0 || 1
	 */
	String CHALLENGE_RESPONSE = "challenge_response";
	
	/* Wordt gebruikt om een client te informeren van het al dan niet doorgaan van de challenge
	 * Richting: Server -> Client
	 * @param response = 	0 als er een of meerdere clients de challenge geweigerd hebben.
	 * 						1 als alle clients de challenge geaccepteerd hebben.
	 * @require response = 0 || 1
	 */
	String CHALLENGE_RESULT = "challenge_result";
	
}
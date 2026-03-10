-- Auth Service

CREATE TABLE IF NOT EXISTS users (
    id              UUID    PRIMARY KEY         DEFAULT gen_random_uuid(),
    username        TEXT    UNIQUE              NOT NULL,
    email           TEXT    UNIQUE              NOT NULL,
    password_hash   TEXT    NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE    DEFAULT now()
);

INSERT INTO users (id, username, email, password_hash) VALUES
('755185f1-46c7-41fb-9258-73f598481f13', 'kevxu', 'kevxu@aa.com', '$2b$12$zqLvTajX9CWoa09x3riWXuLzdSzxdsiztnUz3Yng25f35QB7/dQ/K');   

-- Entitlement Service
CREATE TABLE entitlements (
  id               BIGSERIAL  PRIMARY KEY,
  user_id          UUID       NOT NULL,
  course_id        INTEGER    NOT NULL,
  order_id         UUID       NOT NULL,
  entitled_at      TIMESTAMP  NOT NULL DEFAULT now(),
  CONSTRAINT uq_user_course   UNIQUE(user_id, course_id)
);
CREATE INDEX idx_ent_user   ON entitlements(user_id);
CREATE INDEX idx_ent_course ON entitlements(course_id);

-- Purchase Service
CREATE TABLE orders (
  order_id        UUID              PRIMARY KEY,
  user_id         UUID              NOT NULL,
  course_ids      INTEGER[]         NOT NULL,
  amount          DECIMAL(10,2)     NOT NULL,
  currency        VARCHAR(3)        NOT NULL DEFAULT 'USD',
  status          VARCHAR(20)       NOT NULL,
  payment_gateway VARCHAR(50),
  gateway_txn_id  VARCHAR(100),
  created_at      TIMESTAMP         NOT NULL DEFAULT now(),
  updated_at      TIMESTAMP         NOT NULL DEFAULT now(),
  refunded_at     TIMESTAMP,
  refund_reason   TEXT
);
CREATE INDEX idx_orders_user   ON orders(user_id);
CREATE INDEX idx_status        ON orders(status);

-- Course Service
CREATE TABLE IF NOT EXISTS contents (
    course_id INTEGER NOT NULL,
    seq INTEGER NOT NULL,
    french TEXT NOT NULL,
    english TEXT NOT NULL,
    PRIMARY KEY (course_id, seq)
);

CREATE TABLE IF NOT EXISTS notes (
    course_id INTEGER NOT NULL,
    note_seq INTEGER NOT NULL,
    content TEXT NOT NULL,
    related_sentence_seq INTEGER,
    PRIMARY KEY (course_id, note_seq)
);

INSERT INTO contents (course_id, seq, french, english) VALUES
(1, 1, 'Bonjour^^1^^ Jeanne, comment allez-vous^^2^^ ?', 'Hello Jeanne, how are you (how go-you)?'),
(1, 2, 'Bien, et vous ?', 'Well, and you?'),
(1, 3, 'Ça va^^3^^ très bien, merci.', '(It goes) Very well, thanks.'),
(1, 4, 'Je vous présente^^4^^ ma fille, Chloé.', 'Let me introduce ( present you) my daughter, Chloé.'),
(1, 5, 'Bonjour, Chloé. Comment ça va^^5^^ ?', 'Hello, Chloé. How are you (it goes)?'),

(2, 1, 'Monsieur, madame, vous désirez ?^^1^^', 'Sir, Madam, [what] would you like (you desire)?'),
(2, 2, 'Deux cafés^^2^^ et deux croissants, s''il vous plaît^^3^^.', 'Two coffees and two croissants, please (if it pleases you).'),
(2, 3, 'Non, je préfère une tartine beurrée^^4^^ pour le petit-déjeuner^^5^^.', 'No, I prefer a slice of buttered bread for (the) breakfast.'),
(2, 4, 'Donc, deux expressos, un croissant et une tartine^^6^^ ?', 'So, two espressos, one croissant and one slice of buttered bread?'),
(2, 5, 'Oui, c''est ça. Le croissant est pour moi et la tartine pour elle.', 'Yes, that''s right (this-is it). The croissant is for me and the bread for her.'),

(3, 1, 'Je me présente: je m''appelle^^1^^ Sophie Mercier.', '[Let me] introduce myself ( introduce me): I am (I call-myself) Sophie Mercier.'),
(3, 2, 'Et voici mon ami Loïc Le Gall. Il est breton.', 'And here is my friend Loïc Le Gall. He is Breton.'),
(3, 3, 'Et vous, êtes-vous^^2^^ bretonne^^3^^ aussi ?', 'And you, are you Breton, too?'),
(3, 4, 'Pas du tout, je^^4^^ suis de Nîmes, dans le Midi de la France.', 'Not at all, I am from Nîmes, in the south of France.'),
(3, 5, 'Mais maintenant nous sommes^^5^^ parisiens.', 'But now we are Parisians.'),

(4, 1, 'Pardon, est-ce que^^2^^ vous avez l''heure^^1^^ ?', 'Excuse me (pardon), do you have the time (hour)?'),
(4, 2, 'Je n''ai pas^^3^^ de montre mais je pense qu''il^^4^^ est midi^^5^^ dix.', 'I don''t have a watch, but I think (that) it is ten past noon (noon ten).'),
(4, 3, 'Mais comment le^^6^^ savez-vous ?', 'But how do you know that (how it you-know)?'),
(4, 4, 'Parce que j''ai rendez-vous avec ma femme à midi', 'Because I''m meeting (I have an appointment with) my wife at noon'),
(4, 5, 'et elle a toujours dix minutes de retard!', '... and she is (has) always ten minutes (of) late!'),

(5, 1, 'Excusez-moi, je cherche^^1^^ le métro^^2^^ Saint-Michel.', 'Excuse me, I [am] look[ing] for the Saint-Michel metro [station].'),
(5, 2, 'Désolée^^3^^, madame^^4^^, je ne suis pas d''ici.', 'Sorry, madam, I''m not from here.'),
(5, 3, 'Mais attendez une minute, j''ai un plan de la ville^^5^^.', 'But wait a minute, I have a map of the city.'),
(5, 4, 'Voilà^^6^^: traversez le boulevard et tournez à gauche à la fontaine.', 'Here [we are]: cross the boulevard and turn (to) left at the fountain.'),
(5, 5, 'Merci beaucoup pour votre aide!', 'Thanks very much (a lot) for your help!'),

(6, 1, 'Bonsoir^^1^^ monsieur, bonsoir madame. Bienvenue à l''Hôtel^^2^^ Molière.', 'Good evening, sir; good evening, madam. Welcome to the Molière Hotel.'),
(6, 2, 'Bonsoir, nous avons une chambre réservée pour deux nuits.', 'Good evening, we have a room reserved for two nights.'),
(6, 3, 'Quel est votre nom^^3^^, s''il vous plaît ?', 'What is your name, please?'),
(6, 4, 'Je m''appelle Bailly: B-A-I deux L-Y. Alain.', 'My name is (I call-myself) Bailly: B-A-I-double-L-Y. Alain.'),
(6, 5, 'Absolument: une grande chambre avec un grand lit^^4^^ et une salle de bains.', 'Absolutely: a large room with a double (big) bed and a bathroom (room of bath).'),
(6, 6, 'C''est au quatrième étage. Voici la clé.', 'It''s on (at) the fourth floor. Here''s the key.'),
(6, 7, 'Où sont vos^^5^^ bagages ?', 'Where are your bags (your luggage)?');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(1, 1, '**bonjour** literally means good (*bon*) day (*jour*). It can be used as the equivalent of *good morning* but also as a formal way of saying *hello* throughout the day until around 6 pm.', 1),
(1, 2, '**allez** comes from the irregular verb **aller**, *to go*, the verb used to enquire about someone''s health or well-being (instead of *to be* in English. *How are you?*). **Allez** is the form used with the formal address for *you* (**vous**) when speaking to people other than close friends or family.', 1),
(1, 3, '**va** is the third-person singular (he/she/it) of **aller**.', 3),
(1, 4, '**présenter** means *to present* but, in this context, *to introduce*. **Je vous présente** is the equivalent of *May I introduce / I would like to introduce*, etc.', 4),
(1, 5, '**Comment ça va ?** *How are you doing?* is equivalent to **Comment allez-vous ?**, but slightly more familiar. Here, Jeanne (the female equivalent of the masculine forename Jean) is talking to her friend''s daughter, so she uses a less formal phrase.', 5),

(2, 1, 'This is the easiest way to ask a question in French: use the affirmative (**vous désirez**, *you want*) but with a rising intonation at the end of the sentence.', 1),
(2, 2, '**un café** is both a beverage (*a coffee*) and the place where you drink it (*a cafe*). If you order **un café** in France, you will get a shot of espresso without milk, also called **un expresso** or **un express**.', 2),
(2, 3, 'Although **s''il vous plaît** ("if it pleases you") may seem very formal, it isn''t. It just means *please*.', 2),
(2, 4, '**une tartine beurrée** (or simply **une tartine**) is a slice of buttered bread, a popular breakfast alternative to a croissant. **Beurrée** is the adjective formed from **le beurre**, *butter*. In this sentence, it ''agrees'' with the noun **une tartine**, which is feminine, so we add another -e: **beurrée**. More on the question of agreement later.', 3),
(2, 5, '**le déjeuner** means *lunch*, so **le petit-déjeuner** (literally "small lunch") is *breakfast*. Logical!', 3),
(2, 6, 'All French nouns have a gender: they are either masculine or feminine. A masculine noun is indicated by the articles **un/le**, *a/the*, and a feminine noun by **une/la**. Whenever you learn a new noun, make sure you learn its gender! Note that French does not have a separate word for *one*, so **un café** can mean *a coffee* or *one coffee*, depending on the context.', 4),

(3, 1, '**appeler**, *to call*. **Je m''appelle** literally means "I call myself," but is equivalent to *My name''s*... French can sometimes seem very formal (**s''il vous plaît** for *please*, see Note 3 Lesson 2), but you''ll soon get used to it.', 1),
(3, 2, 'We saw in the last lesson that you can ask a question simply by raising the intonation of an affirmative phrase. Here is a more formal-but very simple-way of forming a question with the verb **être** (*to be*): you simply switch the verb and pronoun **Vous êtes Breton ? -> Êtes-vous Breton ?**', 3),
(3, 3, 'Remember that every noun is either masculine or feminine. But some nouns, particularly those describing men and women, have two forms: **bretonne** is the feminine form of **breton**.', 3),
(3, 4, 'The first person pronoun **je**, *I*, does not take an initial capital unless it is the first word of the sentence.', 1),
(3, 5, 'Now you know the main forms of **être**: **je suis**, **il est**, **vous êtes**, **nous sommes**, *I am, he is, you are, we are*.', 5),

(4, 1, 'We know that **le** and **la** are, respectively, the masculine and feminine definite articles (*the*). But if the noun begins with a vowel or an h, we use **l''**. You see how important it is to learn your genders! **L''heure** (it''s feminine) literally means *the hour*, but we also use the word when asking the time: **Avez-vous l''heure ?**, *Do you have (i.e. can you tell me) the time?*', 1),
(4, 2, 'Another very common way of asking a question is to put **est-ce que** (literally, "is it that") before the verb. So **Avez-vous l''heure ?** and **Est-ce que vous avez l''heure ?** have the same meaning.', 1),
(4, 3, 'To form the negative, you need two words, **ne** (or **n''** before a vowel or an h) directly before the verb, and **pas** directly after it: **Je n''ai pas l''heure**, *I don''t have the time*.', 2),
(4, 4, 'French does not have a neutral pronoun such as *it*. You have to use either **il** or **elle**, depending on the gender of the noun. In neutral contexts, such as when you are telling the time, always use **il**.', 2),
(4, 5, 'In the last lesson, we saw that **le Midi** is the south of France. The word also means *noon* ("midday").', 2),
(4, 6, 'Here, the article **le** means *it* or *that*. Notice that it is placed before the verb, not afterwards, as in English.', 3),

(5, 1, 'French does not have a separate verb form to express a present continuous action (e.g. *I am looking*). Instead, you use the simple form (*I look*), which makes life much easier!', 1),
(5, 2, '**le Métropolitain**, known universally as **le métro**, is the underground railway system (subway) of major cities such as Paris, Marseille or Lyon. The word is also used to refer to a specific station: **le métro Châtelet**, *the Châtelet metro station*, as well as to the train itself. (You can also ask for **une station de métro**, *a metro station*.)', 1),
(5, 3, 'As we will see throughout this course, a substantial portion of English vocabulary is derived from French, and, in many cases, the imported words or expressions are quite formal. For instance, while **désolé** is the root of *desolate* and *desolation*, it is an ordinary, everyday word equivalent to the Germanic-origin *sorry*. **Je suis désolé**, *I''m sorry*.', 2),
(5, 4, 'You will notice that French people use **madame** and **monsieur** a lot when addressing strangers. This is not as formal as it might sound in English, which lacks a convenient, polite way of catching someone''s attention.', 2),
(5, 5, '**une ville**, *a city* or *a town*, French makes no difference between the two.', 3),
(5, 6, '**voilà** is the companion word to **voici** (lesson 3 line 2). In principle, we use **voici** to designate something or someone located close to us (like *here is/are*) and **voilà** for something farther away (*there is/are*). But in practice, we use **voilà** in both instances. For instance, **Voilà le métro**, *Here''s the metro station/train*. We can also use it at the beginning of a sentence to present something or provide information. We''ll see **voilà** and **voici** again in different contexts in the coming weeks.', 4),

(6, 1, '**bonsoir**, *good evening*, is the formal greeting used after 6 pm. (See Lesson 1 note 1).', 1),
(6, 2, 'Remember that the definite article **l''** replaces **le** or **la** in front of a word beginning with a vowel or an h. **Un hôtel** is masculine.', 1),
(6, 3, '**le nom**, *the name*. The word generally refers to a person''s surname, the proper term of which is **le nom de famille**, *family name*. **Le prénom** (literally "pre-name") is the term for the *first name*.', 3),
(6, 4, '**grand** is an adjective meaning *big* or *large*. Adjectives ''agree'' with the gender of the noun they qualify, so we say **un grand lit**, *a large bed*, but **une grande chambre**. You see now why learning noun genders is so important.', 5),
(6, 5, 'Here''s another type of agreement: pronouns also need to change depending on whether the noun is plural or singular. **Vos** is the plural of **votre**: **votre nom**, *your name*, but **vos bagages**, *your bags*. We''ll learn more about agreements later on.', 7);

INSERT INTO contents (course_id, seq, french, english) VALUES
(8, 1, 'Bonjour mademoiselle, est-ce que votre père est à la^^1^^ maison ?', 'Good morning (Good-day), miss. Is your father at home (Is it that your father is at the house)?'),
(8, 2, 'Non, monsieur; il est au^^1^^ bureau aujourd''hui^^2^^.', 'No, sir; he is at the office today.'),
(8, 3, 'À quelle heure est-ce qu''il rentre après le travail ?', '(At) what time (hour) [does] he come back after (the) work?'),
(8, 4, 'Oh, pas avant huit heures normalement.', 'Oh, not before 8 o''clock (hours) normally.'),
(8, 5, 'Vous voulez l''adresse de son bureau?', '[Do] you want the address of his office?'),
(8, 6, 'Oui, s''il vous plaît.', 'Yes, (if you please).'),
(8, 7, 'Attendez un moment, je cherche^^3^^ mon carnet^^4^^ d''adresses.', 'Wait a moment, I [am] looking for my address book.'),
(8, 8, 'Voilà. Sept rue Marbeuf, dans le huitième.', 'There [it is]. 7 rue (street) Marbeuf, in the 8th [district].'),
(8, 9, 'Merci beaucoup^^5^^, mademoiselle. Au revoir.', 'Thank you very much, miss. Goodbye.'),
(8, 10, 'De rien, monsieur. Au revoir.', 'You''re welcome (of nothing), sir. Goodbye.'),

(9, 1, 'Ce^^1^^ monsieur^^2^^ s''appelle Jérôme Laforge et cette^^1^^ dame est sa femme.', 'This gentlemen is called (calls-himself) Jérôme Laforge and this lady is his wife.'),
(9, 2, 'Ils sont à la mairie pour demander une nouvelle carte d''identité pour leur fils.', 'They are at the town hall to (for) ask [for] a new identity card for their son.'),
(9, 3, 'Quel âge a^^3^^ cet enfant^^1^^ ?', 'How old is (what age has) this child?'),
(9, 4, 'Il a huit ans^^4^^, monsieur.', 'He is (has) eight years [old], sir.'),
(9, 5, 'Et il s''appelle Laforge? Est-ce que c''est votre enfant ?', 'And he is called (calls-himself) Laforge? Is it [he] your child?'),
(9, 6, 'Oui, monsieur.', 'Yes, sir.'),
(9, 7, 'Bien. Et il habite chez^^5^^ vous ?', 'Fine. And he lives with (at) you?'),
(9, 8, 'Mais évidemment, avec moi et sa mère !', '(But) obviously, with me and his mother.'),

(10, 1, 'D''accord^^1^^. Je fais mon travail, c''est tout.', 'OK. I''m doing my job, that''s all.'),
(10, 2, 'Est-ce que vous avez le formulaire B-52 ?', 'Do you have (the) form B-52?'),
(10, 3, 'Oui monsieur, nous l''avons.', 'Yes, sir, we have it (we it have).'),
(10, 4, 'Et l''imprimé A-65?', 'And the printed [form] A-65?'),
(10, 5, 'Ça aussi, nous l''avons.', 'That also, we have it.'),
(10, 6, 'Ah bon? Mais est-ce que vous avez son passeport^^2^^ ?', 'Oh really (good)? But do you have his passport?'),
(10, 7, 'Bien sûr. Nous avons même^^3^^ sa^^2^^ photo.', 'Of course. We have even his photo.'),
(10, 8, 'Très bien. Alors je vous fais^^4^^ la carte. Voilà.', 'Very well. So I''ll do (am-doing) you the card. Here it is.'),
(10, 9, 'Réglez à la caisse^^5^^, s''il vous plaît.', 'Pay at the cash desk, please.'),
(10, 10, 'Zut !^^6^^ Je ne trouve^^4^^ pas mon portefeuille!', 'Damn! I can''t find (not find not) my wallet!'),

(11, 1, 'Pourquoi^^1^^ allons-nous au marché ? Il est trop cher.', 'Why are we going (go we) to the market? It''s too expensive.'),
(11, 2, 'Parce que tous^^2^^ les placards sont vides!', 'Because all the cupboards are empty.'),
(11, 3, 'Nous avons besoin de^^3^^ tout^^2^^: de fruits et de légumes,', 'We (have) need (of) everything: (of) fruit, (of) vegetables,'),
(11, 4, 'mais aussi de pain, de fromage, de beurre, de crème, de jambon, et...', 'but also (of) bread, (of) butter, (of) cream and...'),
(11, 5, 'Bon, je comprends. Il n''y a rien à manger. Allons-y.', 'OK (good), I understand. There''s nothing to eat. Let''s go (there).'),
(11, 6, 'Bonjour madame. Qu''est-ce que je peux faire pour vous ?', 'Good morning madam. What can I do for you?'),
(11, 7, 'Je vais acheter une livre^^4^^ de cerises, un kilo de pommes,', 'I am going (go) to buy a pound of cherries, a kilo of apples,'),
(11, 8, 'trois cents grammes de champignons, s''ils ne sont pas trop chers,', '300 grams of mushrooms, if they''re not too expensive,'),
(11, 9, 'quelques^^5^^ bananes, deux kilos de pommes de terre et un peu de lait frais.', 'a few bananas, two kilos of potatoes (apples of earth) and a little fresh milk.'),

(12, 1, 'Et avec ceci ? Vous voulez des^^1^^ fraises, peut-être ?', 'And with that? [Do] you want some strawberries, perhaps?'),
(12, 2, 'Est-ce que je peux les goûter ?', 'Can I taste them (Is it that I can them taste)?'),
(12, 3, 'Allez-y^^2^^. N''hésitez pas! Toutes mes fraises sont bio^^3^^.', 'Go ahead (go-there). Don''t hesitate. All my strawberries are organic.'),
(12, 4, 'Mm, c''est vrai, elles sont vraiment délicieuses. Elles sont à combien^^4^^ ?', 'Mm, it''s true, they''re really (truly) delicious. How much are they?'),
(12, 5, 'Le prix ? Elles ne sont pas chères^^5^^. Seulement quinze euros le kilo.', 'The price? They''re not expensive. Only 15 euros a (the) kilo.'),
(12, 6, 'Non, c''est trop cher^^5^^. J''ai tout^^6^^ ce que je veux pour l''instant.', 'No, it''s too expensive. I have all (everything) that I want for the time being (the instant).'),
(12, 7, 'Alors, ça vous fait vingt-six euros soixante s''il vous plaît.', 'Right (Then), that makes (you) 26 euros 60 please.'),
(12, 8, 'Voilà trente.', 'Here [is] 30.'),
(12, 9, 'Et voici votre monnaie. Bonne journée.', 'And here''s your change. [Have a] good day.'),

(13, 1, 'Louise, Lucas! Venez voir mon cadeau d''anniversaire !', 'Louise, Lucas! Come [and] see my birthday present!'),
(13, 2, 'Qu''est-ce que c''est^^1^^ ?', 'What is it (what is that it is)?'),
(13, 3, 'Vous ne savez pas ?', 'Don''t you know (you not know)?'),
(13, 4, 'C''est un nouveau^^2^^ téléphone.', 'It''s a new phone.'),
(13, 5, 'Il fait absolument tout.', 'It does absolutely everything (all).'),
(13, 6, 'Vous pouvez^^3^^ envoyer des messages, commander un repas,', 'You can send messages, order a meal,'),
(13, 7, 'payer^^4^^ vos courses, écouter la musique, regarder des vidéos...', 'pay [for] your shopping, listen [to] music, watch videos...'),
(13, 8, 'et vous pouvez même parler à quelqu''un.', 'and you can even speak to someone.'),
(13, 9, 'Est-ce que je peux^^3^^ l''essayer ?', 'Can I try it (Is it that I can it-try)?'),
(13, 10, 'Non, malheureusement. Ce n''est pas possible.', 'No, unfortunately. It''s not possible.'),
(13, 11, 'Il ne marche pas^^5^^ ?', 'Isn''t it working? (It doesn''t walk)'),
(13, 12, 'Je ne connais^^6^^ pas le code secret.', 'I don''t know the (secret) [pass]code.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(8, 1, 'We have seen that there are fewer prepositions in French than in English. Thus **à la** can mean *to the, at the* or *in the*, depending on the preceding verb. We say **à la** if the noun is feminine: **à la maison**, *at home* and **au** if the noun is masculine: **au bureau**, *at the office*. Remember, all nouns are either masculine or feminine.', 1),
(8, 2, 'We know that **jour** means *day* (as in **bonjour**, *good day*, or, more generally, *hello*). The adverb **aujourd''hui** means *today*.', 2),
(8, 3, 'Remember that the present tense, **temps présent** in French translates both the simple and continuous forms of our present tense: **je cherche**, *I look for* and *I''m looking for*.', 7),
(8, 4, '**un carnet** is a common word that crops up in many guises. The basic meaning is *a notebook* but, if you take the Paris metro, you can buy **un carnet de tickets**, *a book of tickets*, which is cheaper than buying tickets individually. **Un carnet d''adresses**, *an address book*. (Notice that **une adresse** has only one "d").', 7),
(8, 5, '**beaucoup** is an adverb of quantity that translates *much, many* (and *a lot of*), making no distinction between countable and uncountable nouns: **beaucoup de temps**, *much time*, **beaucoup de croissants**, *many croissants*. **Merci beaucoup**, *Thanks very much*, *Thanks a lot*.', 9),

(9, 1, '*this* or *that* is **ce** for a masculine noun and **cette** for a feminine noun. **Ce garçon**, *this boy*, **cette femme**, *this woman*. But if a masculine noun begins with a vowel or a silent h, we write **cet**: **cet ami**, *this friend*; **cet homme**, *this man*. (**cette** and **cet** are pronounced the same). You see why it''s so important to learn the gender of each and every noun!', 1),
(9, 2, '**un monsieur** is used as a noun in formal French to mean *a gentleman*. (We saw this word used as a greeting in Lesson 2 line 1.)', 1),
(9, 3, 'Don''t confuse the preposition **à** (*at, to*, etc.) with **a**, the third person singular of the verb **avoir** (*to have*). The pronunciation is the same but the grave accent (`) shows the grammatical difference between the two words.', 3),
(9, 4, 'In French, you *have* your age, whereas in English you *are* your age: **elle a dix ans**, *she is 10 years old*; **quel âge a cet enfant ?**, *how old is this child?* Unlike in English, we always add **ans**, *years* after the age: **vingt ans**, *20 years old*.', 4),
(9, 5, '**chez** [shay] means basically "home of": **chez moi**, *my place, my home* (it comes from the Latin word for house, *casa*). But **chez** can also mean *the shop of*, **chez le boulanger**: *at the baker''s*. We''ll see some "abstract" uses of **chez** later on in the course.', 7),

(10, 1, '**d''accord** is used to express agreement or consent (it''s also the origin of the English word accord). In everyday speech, however, many French speakers simply use the universally understood *OK* (or even *OK, d''accord!*).', 1),
(10, 2, 'Unlike English, the possessive adjective in French agrees with the gender of the object possessed, not the owner. In the previous lesson, we learned **son bureau**. Why **son**? Because **le bureau** is masculine. Here, we have **son passeport** and **sa photo** (**une photo**), both of which "belong" to the young boy. But what matters, as far as the possessive adjective is concerned, is the gender of the noun. We''ll go into greater detail in Lesson 14.', 6),
(10, 3, '**même** has several meanings: here it means *even*. Followed by **que** it means *the same as*. For the time being, simply remember this usage. Other forms will crop up later.', 7),
(10, 4, 'Notice how the present simple tense in French can express an immediate future (**je vous fais**, *I''m doing = I will do*) as well as the auxiliary *can* (**je ne trouve pas**, *I don''t find = I can''t find*). Don''t worry about the rule for the time being, just remember these two examples.', 8),
(10, 5, '**régler** is a formal way of saying *to pay* (similar to our *settle up*). **Une caisse** is a cash desk, checkout, etc.', 9),
(10, 6, '**Zut** = a mild, inoffensive expletive to express annoyance, similar to our *damn, heck*, etc.', 10),

(11, 1, '**pourquoi** (literally: "for-what"): *why*. **Parce que**, *because*, is always spelled with two words.', 1),
(11, 2, 'When used as an adjective, **tout**, *all / every*, has to "agree" in number and gender with its noun: **tout le fromage**, *all the cheese* (masculine singular); **toute la journée**, *all day* (feminine singular); **tous les fruits**, *all the fruit* (masculine plural), **toutes les pommes**, *all the apples* (feminine plural). It is also a pronoun (line 2): **J''ai besoin de tout**, *I need everything*.', 2),
(11, 3, '**avoir besoin de**, *to need*. Note that in very formal English, we use exactly the same construction, *to have need of*.', 3),
(11, 4, '**une livre**, *a half kilo* (500g, almost equivalent to one pound). To order by weight, you can also ask for **un kilo** or the number of grams, **huit cents grammes**, *800 grams*. (**Une livre** is also used for a pound sterling.)', 7),
(11, 5, '**quelque**, *some / a few*. It takes an ''s'' in the plural: **Quelques champignons**, *a few mushrooms*. **Quelqu''un**, *somebody*, **quelque chose**, *something*. **Quelque part**, *somewhere*.', 9),

(12, 1, '**des** in this context is an indefinite article. It is often translated by *some* in English: **Je veux des fraises**, *I want some strawberries*, but, depending on the context, it can also be omitted (*I want strawberries*). We now know all three indefinite articles, **un** (masculine), **une** (feminine) and **des** (plural for both genders).', 1),
(12, 2, '**Allez-y** is a useful expression whenever you want someone to go ahead and do something, try something out, walk in front of you, etc. It is translated by *Go on / Go ahead*, etc. It can also be used in the first person plural: **Allons-y**, *Let''s go* and with the familiar form of you, which we will learn in due course.', 3),
(12, 3, '**bio** is an shortened form of **biologique** (literally "biological"). It means *organic*. Because the adjective is idiomatic, it does not agree with the noun.', 3),
(12, 4, '**combien (de)**, *how much/how many?* **Combien de kilos?**, *How many kilos?* **Combien de beurre ?**, *How much butter?* The phrase **Ils/Elles sont à combien ?** is a common, idiomatic way of asking the price of something.', 4),
(12, 5, 'As we have seen, **cher** -like all adjectives- agrees in number and gender with its noun. Masculine adjectives ending in "er" are changed to feminine by putting a grave accent over the "e" and adding a final, silent "e": **le beurre n''est pas cher**, **la livre de fraises est chère**, *the butter isn''t expensive, the pound of strawberries is expensive*. When used as an adverb, **cher** always takes the masculine form: **C''est très cher**, *It''s very expensive*. As we progress, we''ll learn more about how the masculine gender takes precedence over the feminine.', 5),
(12, 6, '**tout** is used as an indefinite pronoun, meaning *everything*. See lesson 11 note 3.', 6),

(13, 1, '**Qu''est-ce** means *What is this/that*. But in everyday French, we usually add **...que c''est** (literally... *that it is*), so we say **qu''est-ce que c''est...?**. There is no difference in meaning, and the answer starts with **C''est...**', 2),
(13, 2, 'We know that adjectives usually come after the nouns they qualify: **un téléphone portable**, *a mobile phone*. But some are placed before the noun. That is the case with **nouveau** (feminine **nouvelle**), *new*. We will learn more about these exceptions later on. (Incidentally, the French word for a phone with computer functions is... **un smartphone**!).', 4),
(13, 3, '**pouvez** and **peux** are respectively the second person plural and the second person singular of the verb **pouvoir**, *can/to be able to*. The first person plural is **pouvons**. Notice that the verb which follows **pouvoir** is in the infinitive: **vous pouvez essayer mon téléphone**, *you can try my phone*.', 6),
(13, 4, 'Some English verbs that are followed by a preposition (*pay for, listen to, look at*, etc.) are expressed with a single verb in French: **écouter la musique**, *listen to music*, **payer un repas**, *to pay for a meal*. There are no hard-and-fast rules on adding these prepositions, so the best way to remember any differences between French and English is to write them down.', 7),
(13, 5, '**marcher** means *to walk* (it''s the origin of our word *march*), but the verb is used colloquially in the sense of *to function, to work*. **Cette montre ne marche pas**, *This watch isn''t working*. The expression **Ça marche !** is used idiomatically to indicate that the person being addressed understands or agrees. **- Deux cafés s''il vous plaît. - Ça marche !** *-Two coffees please - Coming up!*', 11),
(13, 6, 'There are two ways of saying *I know* in French. We say **je sais** when referring to a fact or some other abstract thing, and **je connais** for a person or a place. **Je connais sa mère**, *I know his/her mother*. **Nous ne connaissons pas cette ville**, *We don''t know this town*. **Il sait beaucoup de choses**, *He knows many things*. Both verbs are irregular, and the infinitives are **savoir** and **connaître**. We''ll see them again later on.', 12);

INSERT INTO contents (course_id, seq, french, english) VALUES
(15, 1, 'Bonjour mesdames, bonjour mesdemoiselles, bonjour messieurs^^1^^.', 'Good morning ladies, good morning young ladies, good morning gentlemen.'),
(15, 2, 'Mon nom est Michèle Laroche et je suis votre guide ce matin.', 'My name is Michèle Laroche and I am your guide this morning.'),
(15, 3, 'Nous traversons actuellement^^2^^ la place de la Concorde.', 'We are crossing at present (currently) Concorde Square (place of the Concorde).'),
(15, 4, 'Devant vous, vous pouvez voir^^3^^ le Louvre et, à droite, la Tour^^4^^ Eiffel.', 'In front of you, you can see the Louvre and, on (to) [the] right, the Eiffel Tower.'),
(15, 5, 'S''il vous plaît^^5^^ madame, où sont... ?', 'Please, madam, where are...'),
(15, 6, 'Un instant. Laissez-moi terminer, s''il vous plaît^^5^^.', 'Just a minute (one instant). Let me finish please.'),
(15, 8, 'Eh bien, qu''est-ce que vous voulez savoir ?', 'Well, what do you want to know?'),
(15, 9, 'Où sont les toilettes^^6^^ ?', 'Where is the toilet?'),

(16, 1, 'Comparé à d''autres capitales, comme Moscou ou Pékin, Paris n''est pas très grand.', 'Compared to some other capitals, like Moscow or Beijing, Paris is not very big.'),
(16, 2, 'Mais la région parisienne, c''est-à-dire la ville et sa banlieue, est grande comme Londres.', 'But the Parisian region, that is to say the city and its suburb[s], is as big as London.'),
(16, 3, 'On^^1^^ l''appelle La Ville lumière, avec ses grands^^2^^ monuments et ses longues_avenues,', 'It is called (one it-calls) The City [of] Light, with its great monuments and long avenues'),
(16, 4, 'ses grandes^^2^^_églises et ses vieilles^^2^^ rues.', 'its grand churches and its old streets.'),
(16, 5, 'Regardez^^3^^ là-bas: ce bâtiment superbe^^4^^ est l''Opéra,', 'Look over there: this superb building is the Opera,'),
(16, 6, 'construit par le grand_architecte^^5^^ Charles Garnier.', 'built by the great architect Charles Garnier.'),
(16, 7, 'Derrière, vous avez les grands magasins, et, en face, on voit le Café de la Paix.', 'Behind, you have the major department stores (big shops), and, opposite, you can see (one sees) the Café de la Paix (Peace Café).'),
(16, 8, 'C''est un bon endroit pour une photo, et la lumière est bonne^^6^^ aujourd''hui.', 'It''s a good spot (place) for a photo, and the light is good today.'),
(16, 9, 'Vous pouvez faire beaucoup de belles_images.', 'You can take (make) lots of beautiful pictures.'),
(16, 10, 'Si vous voulez, vous pouvez descendre du bus ici, à côté de l''arrêt.', 'If you want, you can get off (descend from) the bus here, next to the stop.'),

(17, 1, 'Dites-moi, quels^^1^^ sont vos projets^^2^^ pour demain ?', 'Tell me, what are your plans (projects) for tomorrow?'),
(17, 2, 'Il y a^^3^^ une nouvelle_exposition à La Piscine que j''ai très_envie^^4^^ de voir.', 'There is a new exhibition at La Piscine (the Swimming Pool that I really want (have very envy to see.'),
(17, 3, 'Vous voulez venir avec moi ?', '[Do you] want to come with me?'),
(17, 4, 'Je ne suis pas sûr: je dois^^5^^ aller chez le médecin cet après-midi.', 'I''m not sure: I have to go to the doctor [in] the (this) afternoon.'),
(17, 5, 'À quelle heure est votre rendez-vous ?', '(At) What time is your appointment?'),
(17, 6, 'Assez tard: vers seize ou dix-sept heures^^6^^. Ça ne laisse pas beaucoup de temps.', 'Quite late: around (towards) four (16 hours) or five (17 hours) o''clock. That does not leave a lot of time.'),
(17, 7, 'Mais on peut y aller aujourd''hui si vous voulez.', 'But we can go (there) today if you want.'),
(17, 8, 'Pourquoi pas? Quelle heure est-il maintenant ?', 'Why not? What time is it now?'),
(17, 9, 'Il est presque treize heures: très précisément, midi quarante-cinq.', 'It''s almost 1 o''clock (nearly 13 hours): very precisely, 12.45 (midday forty-five).'),
(17, 10, 'Donc nous_avons le temps: l''expo^^7^^ ferme à dix-huit heures.', 'So we have (the) time: the exhibition closes at 6 o''clock (18 hours).'),
(17, 11, 'Quelles sont les choses à voir? Et quel est le titre de cette exposition ?', 'What are the things to see? And what is the title of this exhibition?'),
(17, 12, '"Le Sujet^^2^^, l''objet^^2^^ et l''eau". Très profond, mais pas très clair !', '"The Subject, the Object and (the) Water." Very deep (profound) but not very clear!'),

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(15, 1, 'We know that possessive adjectives have singular, plural, masculine and feminine forms (lesson 7) So, when used in a compound word -**monsieur** (*mon sieur*), **madame** (*ma dame*), **mademoiselle** (*ma demoiselle*), respectively "mysire," "my lady," "my damsel"-they follow the usual agreement rule: **monsieur** -> **messieurs**, etc. A casual way of greeting a mixed-sex group of people-often heard in cafés and bistros- is **Messieurs-dames, bonjour**, *Good morning ladies and gentlemen*. The phrase should be recognised but not used.', 1),
(15, 2, 'A number of French words are identical or very similar to English words but have different meanings. **Actuel** means *current*, and the adverbial form **actuellement** means *currently* NOT *actually*.', 3),
(15, 3, 'Remember that any verb which follows **pouvoir**, *to be able to*, is always in the infinitive.', 4),
(15, 4, 'Learning the gender of French nouns is vital, especially since some have two genders, each with a different meaning. Here''s an example: **le tour** (masculine) is *a tour* whereas **la tour** means *a tower* (monument, tower block, etc.) Another example is **la livre** (see lesson 11 note 4), *a pound* (sterling, weight), and **un livre**, *a book*. Only a handful of these dual-gender nouns are used in everyday conversation, but they have to be learned! We''ll look at them in greater detail at the end of the course.', 4),
(15, 5, 'We have already seen two ways to attract attention when asking a question: **Pardon** (lesson 4) and **Excusez-moi** (lesson 5). You can also use **s''il vous plaît**, *please*, in exactly the same way. **S''il vous plaît, où est le métro ?** *Please can you tell me where the metro is?*', 5),
(15, 6, 'Some nouns are singular in English but plural in French, or vice versa. A good example is **les toilettes**, *the toilet*. We''ll learn more of these words as we progress.', 9),

(16, 1, '**on** is the third person singular impersonal pronoun. It has the same meaning as *one* in English but is much less formal. In practical use, it can replace either **nous** (*we*) — **On est en retard**, *We''re late* — or the passive voice. **On appelle Paris "la Ville lumière"**, *Paris is called the City of Light*. We''ll see this quirky pronoun in greater detail later on.', 3),
(16, 2, 'The adjective **grand**, *big*, can be used to mean *great, eminent*, etc. Like all adjectives, it agrees in gender and number with its noun: **un grand architecte** (*a great architect*), **une grande ville** (*a big OR great city*), **ses grands magasins** (*its big stores*), **ses grandes avenues** (*its major avenues*). See Culture Note below. Also, the adjective **vieille** is the irregular feminine form of **vieux** (*old*).', 3),
(16, 3, 'The second person (singular and plural) is used without a pronoun as an imperative: **Regardez !** *Look!* The negative form is regular: **Ne traversez pas!** *Don''t cross!*', 5),
(16, 4, 'Just because an adjective ends in **-e** does not necessarily mean that it''s in the feminine form. Adjectives such as **superbe**, *superb*, **facile**, *easy*, **malade**, *ill*, and **moderne**, *modern*, are both masculine and feminine. See lesson 21.', 5),
(16, 5, 'Likewise, not all nouns ending in **-e** are feminine. This is particularly true with words relating to professions, such as **un architecte**, *an architect*. However, the feminine form can be formed simply by changing the article: **une architecte**. This is a recent development in the French language, which we''ll discuss later in the course.', 6),
(16, 6, 'Some masculine adjectives ending in a consonant are changed to the feminine by doubling the last letter and adding an **-e**: **bon** -> **bonne** (*good*), **ancien** -> **ancienne** (*ancient, old*). To make the plural, simply add an **-s** to either form. See lesson 14.', 8),

(17, 1, 'The interrogative adjective **quel** is the equivalent of *what* or *which*. **Quel est votre nom ?** *What is your name*. Like all adjectives, it agrees in number and gender with the associated noun (**quelle heure, quelles choses**). See lesson 21.', 1),
(17, 2, 'Several English words ending in *-ect* come from French (via Latin). To find a French equivalent, simply remove the **c**. Thus *a project* -> **un projet**, *a subject* -> **un sujet**, *an object* -> **un objet**.', 1),
(17, 3, '**il y a** (literally "it there has") is an invariable construction that basically means *there is* or *there are*: **Il y a une exposition**, *There is an exhibition*, **Il y a deux choses**, *There are two things*. (Be careful: when used with an expression of time, **il y a** it means *ago*: **Il y a trois jours**, *Three days ago*. We''ll see this again when we learn the past tense).', 2),
(17, 4, '**avoir envie de** (the root of our word *envy*) means *to want to, to feel like*: **J''ai envie de voir mes cadeaux**, *I want to see my presents*. **Envie** is invariable but the verb **avoir** has to be conjugated (see lesson 21). The construction is similar in form to **avoir besoin de** (see lesson 11 note 3).', 2),
(17, 5, '**devoir** means both *must* and *to have to* (French makes no distinction between the two notions). The verb is irregular: **je dois, tu dois, il/elle doit** (all three pronounced [dwa]), **nous devons** ([duhvo"]), **vous devez** ([duhvay]), **ils doivent** ([dwav]). Any verb immediately following **devoir** is in the infinitive: **il doit aller...**, *he must/has to go to...*.', 4),
(17, 6, 'The 24-hour clock is used not only in official or formal settings, it is frequently found in ordinary conversation, too. See lesson 21.', 6),
(17, 7, 'Many words, especially long ones, are abbreviated in everyday usage (the process is known as apocope). Rather than **une exposition** or **le petit-déjeuner**, for example, it''s common to hear **une expo** and **le petit-déj**. Although you should avoid using such familiar terms, it''s important to recognise and understand them.', 10);

INSERT INTO contents (course_id, seq, french, english) VALUES
(18, 1, 'Bonjour Monsieur Castille. Nous voulons prendre un rendez-vous avec vous.', 'Good morning Mr Castille. We want [to] make an appointment with you.'),
(18, 2, 'Est-ce que vous pouvez venir le mardi vingt-deux mars ?', 'Can you come [on] (the) Tuesday [the] twenty-second (22) [of] March.'),
(18, 3, 'Je suis libre entre neuf heures et onze heures, ou plus tard dans la journée^^1^^.', 'I''m free between nine o''clock and eleven o''clock, or later (more late) in the day.'),
(18, 4, 'Non, nous sommes pris toute la semaine, du^^2^^ lundi vingt et un au^^2^^ vendredi vingt-cinq.', 'No, we are taken the whole (all the) week, from Monday [the] twenty-first (21) to Friday [the] twenty-fifth (25).'),
(18, 5, 'Avez-vous une autre date ? En mai, par exemple ?', 'Do you have another date? In May, for example?'),
(18, 6, 'Je regrette^^3^^: mai n''est pas possible, à cause des ponts.', 'I''m sorry ( regret): May is not possible, because of the long weekends (bridges).'),
(18, 7, 'Je ne peux pas vous voir avant le mercredi trente juin. Mon emploi du temps est très chargé^^4^^.', 'I can''t see you before (the) Wednesday [the] thirtieth (30) [of] June. My schedule (job of time) is very full (laden).'),
(18, 8, 'Mais nous, nous sommes en voyage^^5^^ en juin et juillet.', 'But we (we, we are travelling (on journey) in June and July.'),
(18, 9, 'Moi, je suis en vacances au mois d''août. Je prends l''avion le jeudi douze pour aller aux États-Unis.', 'Me, I''m on holiday in the month of August. I am flying (take the plane to go) on (the) Thursday [the] twelfth (12) to the United States.'),
(18, 10, 'Septembre est hors de question à cause de la rentrée scolaire.', 'September is out of [the] question because of the new academic year (the return to school).'),
(18, 11, 'Et en octobre j''ai déjà trois conférences et un stage^^6^^ de formation^^6^^. Novembre ?', 'And in October I already have three lectures and a training course. November?'),
(18, 12, 'Ce n''est pas un bon mois: mes parents passent trois semaines chez nous.', 'It''s not a good month: my parents are spending three weeks with us.'),
(18, 13, 'Attendez: je peux vous proposer le samedi vingt-cinq décembre ou le dimanche vingt-six.', 'Wait: I can offer (propose) you (the) Saturday [the] twenty-fifth (25) [of] December or (the) Sunday [the] twenty-sixth (26).'),
(18, 14, 'Mon agenda^^6^^ est enfin vide !', 'My diary is (finally) empty at last!'),

(19, 1, 'Hôtel Sacré Cœur. Comment est-ce que je peux vous aider ?', 'Hôtel Sacré Cœur (sacred heart). How can I help you?'),
(19, 2, 'J''organise une fête pour mon anniversaire et je veux louer une salle.', 'I [am] organising a party for my birthday and I want to rent a room.'),
(19, 3, 'Pour combien^^2^^ de personnes ?', 'For how many of people?'),
(19, 4, 'Une trentaine^^3^^ : il y a la famille, la belle-famille^^1^^, des copains.', 'About thirty: there is the family, the (beautiful) family-in-law, some mates.'),
(19, 5, 'Je veux quelque chose de beau^^1^^ et pas trop cher.', 'I want something lovely (handsome) and not too expensive.'),
(19, 6, 'C''est pour quand, cette fête ? Pas à la fin de l''année, j''espère ?', 'When (it''s for when) is this party? Not at the end of the year, I hope?'),
(19, 7, 'Nous fermons entre Noël et le Nouvel An^^1^^.', 'We close between Christmas and the New Year.'),
(19, 8, 'Pas de problème : c''est pour la soirée^^4^^ du trente juin, jusqu''à minuit.', 'No problem: it''s for the evening of the thirtieth [of] June, until midnight.'),
(19, 9, 'Voyons: j''ai une belle^^1^^ salle pour une cinquantaine^^3^^ de personnes.', 'Let''s see: I have a lovely room for about fifty people.'),
(19, 10, 'C''est un bel^^1^^ endroit pour une fête.', 'It''s a great place for a party.'),
(19, 11, 'Ça coûte combien^^2^^ ? Je n''ai pas un gros budget.', 'How much does it cost (that costs how much)? I don''t have a big budget.'),
(19, 12, 'Alors j''ai quelque chose de plus petit et moins cher:', 'Then I have something (of) smaller (more small) and less expensive:'),
(19, 13, 'le placard à balais: c''est gratuit^^5^^ !', 'the broom cupboard: it''s free!'),

(20, 1, 'Le sujet de l''émission Carte blanche cette semaine est "Un monde idéal".', 'The subject of the programme Carte Blanche (card white) this week is "An ideal world."'),
(20, 2, 'Nous avons posé la question suivante aux^^1^^ ambassadeurs de quatre pays^^5^^:', 'We (have) put the following question to the ambassadors of four countries:'),
(20, 3, 'le Japon, l''Inde, les États-Unis et la France^^2^^.', '(the) Japan, (the) India, (the) United States and (the) France.'),
(20, 4, '"Que voulez-vous pour Noël, Monsieur l''Ambassadeur ?"', '"What do you want for Christmas, Mr (the) Ambassador?"'),
(20, 5, 'Voici leurs réponses, dans l''ordre.', 'Here are their answers, in (the) order.'),
(20, 6, 'L''ambassadeur japonais^^3^^ veut "du^^4^^ bonheur, de la^^4^^ paix et des^^4^^ droits humains".', 'The Japanese ambassador wants "(of the) happiness, (of the) peace and (of the) human rights."'),
(20, 7, 'Son collègue indien^^3^^ veut "de la^^4^^ santé et de l''^^4^^éducation pour tout le monde".', 'His Indian colleague wants "(of the) health and (of the) education for everyone (all the world).'),
(20, 8, 'L''Américain^^3^^ veut "des^^4^^ emplois, de l''^^4^^argent et du^^4^^ bien-être" pour son pays^^5^^.', 'The American wants "(of the) jobs, (of the) money and (of the) well-being (well-to-be)" for his country.'),
(20, 9, 'Mais la réponse de l''ambassadeur français^^3^^ est la plus intéressante.', 'But the answer of the French ambassador is the most interesting.'),
(20, 10, 'Ah bon? Qu''est-ce qu''il veut ?', 'Really (ah good)? What does he want?'),
(20, 11, '"Des^^4^^ chocolats, du^^4^^ vin blanc et de la^^4^^ crème fraîche."', '"(of the) Chocolates, (of the) white wine and (of the) fresh cream."'),
(20, 12, 'Ce n''est pas vrai^^6^^! Il est honnête, au moins!', 'I don''t believe it! (It is not true) He''s honest, at least!');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(18, 1, '**la journée**, *the day*, refers to the period between dawn and dusk: **toute la journée** means *the whole day (or daytime)* rather than a specific day or moment in that day, for which we use **le jour**: **le jour de mon mariage**, *the day of my wedding*. A common, and useful, leave-taking expression is **Bonne journée**, *Have a good day*.', 3),
(18, 2, 'By now you are familiar with the partitive articles **de, de la** and **des**, reviewed in lesson 21. But **de** also means *from* (for example **Il est de Nîmes**, lesson 3). When talking about a period of time (from... to/till), we say **de... à** (**de neuf heures à dix heures**, *from 9 until 10 o''clock*) but if the following noun is preceded by **le, la** or **les**, the partitive becomes **du, de la** or **des**, respectively. For example, **le lundi** et **le jeudi** -> **du lundi au jeudi**.', 4),
(18, 3, '**regretter**, *to regret*, can be used in conversation when refusing something politely: **Je regrette mais je ne peux pas venir demain**, *I''m sorry but I can''t come tomorrow*.', 6),
(18, 4, '**chargé**, the adjective and past participle of **charger**, *to load*, is one of les faux-amis, or false friends, discussed in lesson 7. Used in connection with a timetable or programme, it means *to have a heavy schedule* or *to be very busy* (i.e. "laden" with work).', 7),
(18, 5, '**un voyage** has a broader scope than its English cognate, referring to travel in general (rather than just a sea voyage). It basically means *a journey* or *a trip* - **Le voyage en bus est très long**, *The journey by bus is very long* - but can also refer to travel in general: **une agence de voyages**, *a travel agency*. Be careful not to confuse **une journée** (see note 1) with *a journey*.', 8),
(18, 6, 'Other examples of faux-amis (see note 4) include **un stage**, *a course* or *an internship*, and **la formation**, *training* or *continuing education*, and **un agenda** (line 13), *a schedule*. It''s important to remember these false cognates because they can have very different meanings from one language to the other.', 11),

(19, 1, 'The adjective **beau** has several meanings: *handsome, beautiful, lovely, great*, etc. It is also irregular: the feminine form is **belle** and the masculine plural is **beaux**. But because French does not permit a hiatus (a break between the terminal vowel sound of one word and the initial vowel of the following word), for example **un beau endroit**, there is another masculine form: **bel** -> **un bel endroit**. The same rule applies to **nouveau/nouvelle** (*new*): **nouvel an** (*new year*). Three other adjectives have this additional masculine form. (We have seen a similar construction with **ce/cette**: **ce matin, cette femme**, but **cet après-midi**). Note that **une belle-famille** (with a hyphen) has nothing to do with beauty: it means *a family-in-law*, usually consisting of **une belle-mère** (*mother-in-law*) and **un beau-père** (*father-in-law*).', 5),
(19, 2, '**combien** is a useful word (lesson 12 note 4). Remember that it translates both *how much* and *how many*. One useful phrase is **Ça coûte combien ?** or **Combien est-ce que ça coûte?** *How much does it cost?* (from the verb **coûter**, *to cost*).', 3),
(19, 3, 'The termination **-aine** can be added to a cardinal number, generally a multiple of ten or five (**dix, quinze, vingt**, etc.), to indicate an approximation (**une dizaine**, *about 10*, **une quinzaine**, *about 15*, **une vingtaine**, *about 20*). Note that **une douzaine** can mean *about twelve* OR, when buying eggs, *a dozen* (**une douzaine d''œufs**).', 4),
(19, 4, 'The difference between the two words for the evening, **le soir** et **la soirée**, is the same as for **le matin** and **la matinée**. But **une soirée** can also mean an event held in the evening, such as **une soirée dansante**, *a dinner dance*.', 8),
(19, 5, 'The adjective *free* has two translations: the first, seen in the previous lesson, is **libre** (i.e. no commitments or engagements: **J''ai une soirée libre**, *I have a free evening*), the second is **gratuit** (absence of cost: **Le bus est gratuit ce soir**, *The bus is free this evening*). Moreover, **gratuit** is the root of the English word *a gratuity*, something given freely as a gift.', 13),

(20, 1, 'We know that **au** (*to the*) is the equivalent of **à la** for masculine nouns (lesson 8 note 1). **Aux** is the plural form for both genders. **Cet été, nous allons aux États-Unis** (masc.) / **Je vais aux toilettes** (fem.). Like all plural endings, the **-x** is silent [oh] unless it precedes a vowel.', 2),
(20, 2, 'Country names, like all nouns, are either masculine or feminine. Most of those ending in **-e** are feminine (**la France**, **la Belgique** (*Belgium*), **l''Italie** (*Italy*), etc.); the others are masculine. Some toponyms are plural, notably **les États-Unis**, *the United States*. There are a few exceptions, which we will see later.', 3),
(20, 3, 'Adjectives of nationality do not take an initial capital (**l''ambassadeur américain**, *the American ambassador*), but nouns of nationality do: **un(e) Américain(e)**, *an American man/woman*.', 8),
(20, 4, 'The partitive articles **du, de la** and **des** give information about the quantity of the noun they precede. They are often translated by *some/any* but, in some cases, can be omitted in English. **Du** and **des** are the combined forms of **de le** and **de les**, respectively (see lesson 12 note 1). **Il veut du pain, de la crème et des champignons**, *He wants (some) bread, (some) cream and (some) mushrooms*. If a singular noun following a partitive begins with a vowel (or an h), the article becomes **de l''**, whatever the noun''s gender: (**de l''argent**, masc., **de l''éducation**, fem.). Yet another good reason for learning genders!', 6),
(20, 5, 'Despite the final **-s**, **pays** can be singular as well as plural (**mon pays**, *my country*, **nos pays**, *our countries*). The same applies to nouns ending in **-x** (**le prix/les prix**, *price/prices*) and **-z**, as we will see later on.', 2),
(20, 6, '**vrai(e)**, *true*, can also mean *real* (**la vraie réponse**, *the real answer*). The exclamation **Ce n''est pas vrai!**, *It isn''t true!* can also be used (as in sentence 12) to mean *I don''t believe it!*, *You''re kidding!* In everyday usage, careless speakers tend to drop the negative particle **n''**, but don''t be tempted to imitate them!', 12);

INSERT INTO contents (course_id, seq, french, english) VALUES
(22, 1, 'Je n''aime pas les jeux de hasard, parce qu''ils sont tous risqués. Et vous ?', 'I don''t like (the) games of chance, because they''re all risky. And you?'),
(22, 2, 'Je suis comme vous. Mais il y a un jeu que j''aime bien.', 'I''m like you. But there is one game that I really like (like well).'),
(22, 3, 'Vraiment ? Lequel ? Les machines à sous ?', 'Really? Which one? Slot machines (machines at pennies)?'),
(22, 4, 'Mais non! Ce sont les courses de chevaux.', 'Not at all (but no). It''s (it are) horse races.'),
(22, 5, 'Je regarde tous les journaux spécialisés, surtout un journal intitulé Mille gagnants,', 'I read all the specialised newspapers, especially a paper called (entitied) "[A] Thousand Winners."'),
(22, 6, 'et j''établis une petite liste.', 'and I make (establish) a little list.'),
(22, 7, 'Je réfléchis pendant quelques secondes, et quand je suis prêt,', 'I think (reflect) for a few seconds, and when I''m ready,'),
(22, 8, 'je choisis le cheval qui a une bonne chance de finir en premier.', 'I choose the horse that has a good chance of finishing (to finish in) first.'),
(22, 9, 'Puis je remplis la grille de jeu... et je croise les doigts.', 'Then I fill in the race card (game grid)...and I cross my (the) fingers.'),
(22, 10, 'Au fait, comment est-ce que vous choisissez vos chevaux ?', 'By the way (to-the fact), how do you choose your horses?'),
(22, 11, 'Qu''est-ce que vous espérez ?', 'And what do you hope [for]?'),
(22, 12, 'Je suis comme tous les joueurs; nous avons tous la même idée :', 'I''m like all gamblers (players: we all have the same idea:'),
(22, 13, 'gagner beaucoup d''argent et devenir très riche.', 'to earn (win) a lot of money and to become very rich.'),
(22, 14, 'Au fait, est-ce que vous pouvez me prêter cinquante euros ?', 'By the way, can you lend me fifty euros?'),
(22, 15, 'Je n''ai pas un sou.', 'I''m broke (I don''t have a penny).'),

(23, 1, 'Bonjour, qu''est-ce que je vous sers ?', 'Good morning, what can I get you (what-isit that I you serve)?'),
(23, 2, 'Je veux un café crème, un croque-monsieur et deux billets de loto, s''il vous plaît.', 'I want a white coffee (coffee cream), a toasted ham-and-cheese sandwich ("bite-sir") and two lotto tickets, please.'),
(23, 3, 'Vous pouvez jouer au loto en ligne, vous savez. C''est très simple.', 'You can play (at) the lotto online, you know. It''s very simple.'),
(23, 4, 'Et il n''y a pas de queues au comptoir, comme ce matin.', 'And there are no queues at the counter, like this morning.'),
(23, 5, 'Je sais, mais je préfère venir ici: l''ambiance est sympa.', 'I know, but I prefer to come here: the atmosphere is nice.'),
(23, 6, 'Je saisis l''occasion pour quitter mon appartement et voir d''autres gens.', 'I take (seize) the opportunity to get out of (to leave) my flat and (to see) seeing other people.'),
(23, 7, 'J''ai des clients qui viennent jouer tous les jours.', 'I have customers who come every day.'),
(23, 8, 'Dites-moi: avez-vous un secret pour le loto ?', 'Tell (say) me, do you have a secret for the lotto?'),
(23, 9, 'Tout à fait. Je joue toujours les mêmes numéros :', 'Absolutely (all to fuct). I always play (ploy dalways) the same numbers:'),
(23, 10, 'tous ceux finissant par quatre, plus le soixante-deux, le quarante-trois, le dix-sept, et le cinquante-cinq,', 'all those finishing in (by) 4, plus (the) 62, (the) 43, (the) 17 and (the) 55,'),
(23, 11, 'ma date de naissance: le vingt-trois, douze, soixante-neuf,', 'my birth date: (the) 23-12-69'),
(23, 12, 'et, évidemment, le treize, mon chiffre préféré.', 'and, of course (evidently), (the) 13, my favourite number.'),
(23, 13, 'Avec ça, vous réussissez à gagner ? Je vous applaudis!', 'With that, you manage (succeed) to win? I applaud you!'),
(23, 14, 'Non, pas vraiment, mais j''investis pour l''avenir. Je vais gagner un de ces jours!', 'No, not really, but I''m investing for the future. I''m going to win one day!'),

(24, 1, 'Asseyez-vous, mademoiselle. Qu''est-ce qui ne va pas ?', 'Sit down, miss. What''s the matter (what is it that not go not)?'),
(24, 2, 'Je ne vais pas bien du tout, docteur.', 'I''m not well at all, doctor.'),
(24, 3, 'J''ai mal à la tête, mal aux oreilles et mal au genou droit,', 'I have a headache (bad at the head), an earache (bad at the ears) and a pain (bad or) in my right knee'),
(24, 4, 'et j''ai aussi de la fièvre. Est-ce que c''est grave ?', 'and I also have a temperature (the fever). Is it serious (grave)?'),
(24, 5, 'En effet, vous avez l''air fatiguée. Vous n''êtes pas en forme.', 'Indeed (in effect), you look (have the-aw) tired. You''re not on form.'),
(24, 6, 'Je vais prendre votre température. Mm, vous avez trente-huit.', 'I''m going to take your temperature. Mm, it''s (you have) 38 [100.4°F).'),
(24, 7, 'C''est un peu élevé. Maintenant, ouvrez la bouche. Fermez.', 'That''s a little high. Now, open your (the) mouth. Close.'),
(24, 8, 'Je vais vérifier votre tension et écouter votre cœur. Respirez.', 'I''m going to check your blood pressure (tension) and listen [to] your heart. Breathe.'),
(24, 9, 'Vous avez une bonne vieille grippe, c''est tout.', 'You have (a) good old-fashioned (good ald) flu, that''s all.'),
(24, 10, 'Je vous donne trois médicaments, que vous devez prendre pendant huit jours.', 'I''m giving you three drugs (medicines), which you must take for eight days.'),
(24, 11, 'D''abord, un sirop. Vous le prenez trois fois par jour: le matin, le midi et le soir.', 'Firstly, a syrup. You take it (it take) three times a (by) day: morning, noon and evening.'),
(24, 12, 'Ensuite, des comprimés. Il faut les avaler avec un grand verre d''eau.', 'Next, (some) pills. You have to swallow them (them swallow) with a large glass of water.'),
(24, 13, 'Et enfin, il y a une gélule par jour. Vous la prenez avant le dîner.', 'And lastly, there is one capsule a day. You take it (it take after dinner.'),
(24, 14, 'Voici votre ordonnance et une feuille de maladie.', 'Here is your prescription and a refund form (sheet of illness).');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(22, 1, 'Most nouns ending in **-eu** form the plural with **x**: **un jeu**, **des jeux** (*game(s)*), **un feu**, **des feux** (*fire(s)*). Another set of nouns with an irregular ending are those ending in **-al**. The **l** is deleted and replaced by **-ux**: **un cheval**, **des chevaux** (*horse(s)*), **un journal**, **des journaux** (*newspaper(s)*). There are a couple more of these irregular forms, which we will learn later on.', 1),
(22, 2, '**tous** is the masculine plural of the adjective **tout**, *all*. Placed before a noun, it is pronounced [too], just like the singular (**tous les jeux**, *all the games*). But if **tous** comes after a verb, it means *all of you/them/everyone*, and is pronounced [toos]: **Je les aime tous**, *I like all of them*. Always check the preceding word before trying to pronounce **tous**!', 1),
(22, 3, '**Mais non!**, literally "But no!", is an emphatic contradiction, equivalent to *Of course not!* or *Not at all!* **Vous êtes malade? - Mais non, je vais très bien !**, *Are you ill? Not at all, I''m very well!* Another common exclamatory expression, in line 9 and line 13, is **Au fait**, literally "to the fact". Placed at the beginning of a sentence, it means *By the way*. **Au fait, quel est votre nom?** *By the way, what''s your name?*', 4),
(22, 4, '**établis** is the first person singular of **établir**, *to establish, to draw up*. It belongs to the second major group of verbs, which end in **-ir** and are conjugated like this: **j''établis, tu établis, il/elle établit, nous établissons, vous établissez, ils/elles établissent**. Other common verbs in this group are **choisir**, *to choose*, **finir**, *to finish*, **remplir**, *to fill*, and **réfléchir**, *to think, reflect*. (More details in the next lesson and an overview in lesson 28.)', 6),
(22, 5, '**choisissez** is the second person plural and honorific singular form of **choisir** (see above). Note the pronunciation: [shwahzeessay].', 10),
(22, 6, '**gagner** means *to win*: **Elle gagne toujours quand elle joue**, *She always wins when she plays*. But it also means *to earn (money)*: **Il gagne cinq mille euros par mois**, *He earns five thousand euros per month*. Note the context whenever you come across this very common verb. **Un(e) gagnant(e)**, *a winner (male/female)*.', 13),
(22, 7, '**un sou** is the name of an old French coin. It no longer exists, but the word still crops up in popular expressions — **Je n''ai pas un sou**, *I don''t have a penny/a bean*; **Il est sans le sou**, *He doesn''t have a bean* — as well as in the familiar term **une machine à sous**, *a slot machine*. (Pay attention to the context: **sous** is also a preposition meaning *under*).', 15),

(23, 1, 'Remember to always learn the preposition or adverb that usually follows a verb, particularly when the equivalent English verb does not have one. Here, **jouer**, *to play*, is followed by **à** if the object noun is feminine (**jouer à la loterie**, *to play the lottery*), **au** for a masculine singular noun (**jouer au loto**, *to play the lotto*) and **aux** for a masculine or feminine plural (**jouer aux échecs**, *to play chess*).', 3),
(23, 2, 'The negative particle **pas** is followed by **de** (or **d''** before a vowel) regardless of whether the following noun is singular or plural: **Il n''a pas de billets**, *He doesn''t have any tickets*, **Elle n''a pas d''argent**, *She doesn''t have any money*.', 4),
(23, 3, 'The idiomatic adjective **sympa** is an abbreviated form of **sympathique**, equivalent to *nice, pleasant*, etc. **Michel est une personne très sympa**, *Michel''s a really nice person*. Because the word is an abbreviation, it is invariable in the singular, but it takes a final **-s** in the plural: **Ce sont des personnes très sympas**, *They''re really nice people*. Note that **sympa** is as imprecise as *nice*—and just as common!', 5),
(23, 4, '**autre** is an indefinite adjective, like **tout**, that is used to give a general description: **Choisissez un autre chiffre**, *Choose another figure*. When followed by a plural noun, it is preceded by the partitive **d''**: **Choisissez d''autres chiffres**, *Choose other figures*.', 6),
(23, 5, '**dire** (pronounced [deer]) is an important irregular verb that translates both *to say* and *to tell*. The present tense is **je dis, tu dis, il/elle dit, nous disons, vous dites, ils/elles disent**. **Sami dit qu''il est désolé**, *Sami says he''s very sorry*. **Dites-moi votre nom**, *Tell me your name*.', 8),
(23, 6, '**tout à fait** ("all to fact") is a common expression of agreement or a confirmation, equivalent to *Exactly* or *Absolutely*. **Êtes-vous prêt ? - Tout à fait**, *Are you ready? Absolutely*. It can also be used for emphasis: **Je suis tout à fait d''accord**, *I totally agree*. Remember that French does not use an auxiliary to add emphasis (*I do like that game*), so expressions such as **tout à fait** are very common.', 9),
(23, 7, '**toujours** comes after the verb, in contrast to *always*. **Nous jouons toujours aux mêmes jeux**, *We always play the same games*. And whereas English makes a difference between *always* and *still*, **toujours** covers both notions: **Est-ce que tu habites toujours à Toulouse?** *Do you still live in Toulouse?*', 9),
(23, 8, 'The terms for numbers, figures, digits and numerals are awkward to translate because the terms are not always used precisely. Thus **un chiffre**, which gives us the English word *cipher*, refers to a written figure or a digit: **le chiffre sept** translates as *the figure 7*, and **un numéro** refers to a specific unit such as a phone number or a house number (**numéro de téléphone / de maison**). To complicate matters slightly, there is also the word **un nombre**, which we will see later on.', 12),
(23, 9, 'Second-group verbs ending in **-ir** are characterised by their present participle, which ends in **-issant** (**finir -> finissant**, **applaudir -> applaudissant**, **réussir -> réussissant**, etc.). **Il choisit tous les numéros finissant par huit**, *He chooses all the numbers finishing in eight*.', 10),

(24, 1, '**qu''est ce qui** is an interrogative expression referring to the subject of the sentence: **Qu''est-ce qui est important pour vous ?** *What''s important for you?* Compare it with **qu''est-ce que**, which refers to a direct object: **Qu''est-ce que vous voulez ?** *What do you want?*', 1),
(24, 2, 'We know that **aller**, *to go*, is used to talk about someone''s health (see lesson 1). **Je vais bien**, *I''m well*. The negative form **Je ne vais pas bien** means *I''m not well*. To ask what is wrong, a doctor will say **Qu''est-ce qui ne va pas ?** *What''s not right?*, or, more colloquially, *What''s the matter? / What''s wrong?*', 1),
(24, 3, '**avoir mal** ("to have bad") is an intransitive expression used to talk about pain or discomfort. It is generally followed by **à la** (or **au/aux**) and the painful body part: **J''ai mal au ventre** ("I have bad to the stomach"), *I have a stomach ache*. The word order is often different to the English form: **Elle a mal à la tête**, *She has a headache*, **Il a mal aux pieds**, *His feet hurt*. (Note that there is no distinction between *ache* and *hurt* in French).', 3),
(24, 4, '**une fièvre**, literally *a fever*, is used in everyday speech, generally with **de**, to mean a high temperature: **Mon fils a de la fièvre**, *My son has a (high) temperature*. In a technical context, however, **fièvre** is translated by the cognate: **la fièvre jaune**, *yellow fever*. Note that the Fahrenheit scale is not used in most French-speaking countries (including Canada): all temperatures are in Celsius. So when the doctor says, as in line 6, **Vous avez trente-huit (de fièvre)**, *You have a temperature of 38°C*, the equivalent in Fahrenheit would be 100.4°F.', 4),
(24, 5, 'The masculine noun **l''air** means *the air*. But the meaning of the expression **avoir l''air (de)** is *to look like* or *look as if*. **Marc a l''air fatigué**, *Marc looks tired*. **Elle a l''air d''une femme très sympa**, *She looks like a very nice woman*.', 5),
(24, 6, 'The direct object pronouns are **me**, *me*, **te/vous**, *you*, **le/la**, *him/her/it*, **nous**, *us*, and **les**, *them*. In contrast to English, they come before the verb: **Je les aime**, *I love them*. **Nous la voyons**, *We see her*. Remember, though, that there are no neutral pronouns in French, so the last sentence can also mean *We see it*, if the pronoun is replacing a feminine noun.', 12);

INSERT INTO contents (course_id, seq, french, english) VALUES
(25, 1, 'Il est déjà midi ! J''ai faim, et vous ?', 'It''s already noon. I am hungry (have hunger). And you?'),
(25, 2, 'Un petit peu, mais je vous accompagne avec plaisir.', 'A little bit. But I''ll come with (accompany you with pleasure.'),
(25, 3, 'Je connais plusieurs restaurants dans le quartier :', 'I know several restaurants in the neighbourhood:'),
(25, 4, 'il y a une pizzéria près d''ici, une crêperie dans la rue à gauche, ou une brasserie à droite de l''église.', 'there''s a pizzeria near here, a pancake house in the street on [the] left or a brasserie to [the] right of the church.'),
(25, 5, 'Laquelle est-ce que vous préférez ?', 'Which [one] do you prefer?'),
(25, 6, 'Ça m''est égal. Et vous ?', 'It''s [all] the same (equal) to me. And you?'),
(25, 7, 'La crêperie: elle est excellente et pas chère. Ça vous dit?', 'The pancake house. It''s excellent and not expensive. Does that tempt you (that you speaks)?'),
(25, 8, 'Où est-ce que c''est ? J''espère que ce n''est pas trop loin.', 'Where is it? I hope that it''s not too far.'),
(25, 9, 'Je suis assez pressé parce que j''ai un rendez-vous à quatorze heures.', 'I''m in quite a hurry because I have an appointment at 2pm (14 hours).'),
(25, 10, 'Non, elle est à trois cents mètres d''ici. À seulement cinq minutes à pied.', 'No, it''s (at) 300 metres from here. (AD) only 5 minutes on (to) foot.'),
(25, 11, 'On va tout droit puis à droite et ensuite c''est la troisième rue à gauche.', 'We go (one goes) straight ahead then (to) right and afterwards it''s the third street on [the] left.'),
(25, 12, 'Mais je viens de penser à quelque chose : elle est fermée le lundi.', 'But I have just thought I came to think) of something: it''s closed [on] Monday.'),
(25, 13, 'Allons à la brasserie, alors. Mais faisons vite.', 'Let''s go to the brasserie, then. But let''s make [it] quick.'),

(26, 1, 'Avez-vous une table pour deux s''il vous plaît ?', 'Do you have a table for two, please?'),
(26, 2, 'Si vous voulez bien me suivre. Est-ce que cette table vous convient ?', 'Follow me, please (If you want well me to-follow). Does this table suit you?'),
(26, 3, 'Non. Je veux être près de la fenêtre parce que j''ai chaud.', 'No [it doesn''t]. I want to be close to the window because I am (have) hot.'),
(26, 4, 'Asseyez-vous ici. Je vous apporte le menu et la carte des vins.', 'Sit here. I [will] bring you the menu and the wine list (cara)'),
(26, 5, 'J''arrive tout de suite ... Alors, vous êtes prêts ?', 'I''ll be right there ( -arrive all of following)... So, are you ready?'),
(26, 6, 'Quel menu prenez-vous: celui à vingt euros ou celui à quarante ?', 'Which menu are you taking: the one at 20 euros or the one at 40.'),
(26, 7, 'Le menu à vingt. Quel est le plat du jour ? Sinon, quelles sont les spécialités ?', 'The menu at 20. What is the dish of the day? If not, what are your specials (specialities).'),
(26, 8, 'Il n''y en a pas. Je vous conseille de prendre l''entrecôte ou le saumon froid.', 'We''re out (there aren''t any). I advise you to take the rib steak (between-rib) or the cold salmon.'),
(26, 9, 'Dans ce cas, deux entrecôtes s''il vous plaît.', 'In that case, two rib steaks, please.'),
(26, 10, 'Quelle cuisson pour la viande, et avec quels légumes ?', 'How do want the meat cooked (what cooking for the meat)? And with which vegetables?'),
(26, 11, 'Saignante pour tous les deux, avec des frites.', 'Rare (bleeding) for the two of us, with chips.'),
(26, 12, 'Voulez-vous boire quelque chose ? Du vin ou de la bière ?', 'Do you want something to drink (to drink something)? (Some) wine or (some) beer?'),
(26, 13, 'Juste une bouteille d''eau minérale. Nous avons soif. [...]', 'Just a bottle of mineral water. We are thirsty (have thirst). [...]'),
(26, 14, 'L''addition s''il vous plaît. Est-ce que le service est compris ?', 'The bill please. Is the service included?'),
(26, 15, 'Oui, mais pas le pourboire.', 'Yes, but not the tip (for-drink).'),

(27, 1, 'Quels hôtels sont situés à proximité de l''aéroport ?', 'What hotels are located (Situated) close (at proximity) to the airport?'),
(27, 2, 'Mon vol part très tôt le samedi matin et je n''ai pas envie de le rater.', 'My flight leaves very early on Saturday morning and I don''t want to miss it.'),
(27, 3, 'Pourquoi ne pas faire une recherche sur Internet ?', 'Why not search online (make a research on internet)?'),
(27, 4, 'Bonne idée ! Je me connecte.', 'Good idea! I''ll log on (me connect).'),
(27, 5, 'Il y a un hôtel trois étoiles juste à côté du terminal et un autre à deux kilomètres.', 'There''s a three-star hotel just next to the terminal and another ( ) two kilometres [away].'),
(27, 6, 'Regardons celui qui est le plus près. II s''appelle l''Hôtel des voyageurs.', 'Let''s look at the one which is the nearest (most near). It''s called the Travellers'' Hotel.'),
(27, 7, 'Voici une chambre supérieure: qu''est-ce que vous en pensez ?', 'Here''s a superior room: what do you think of it?'),
(27, 8, 'Je préfère celles au premier étage: elles ont l''air plus confortables.', 'I prefer those on the first floor: they look more comfortable.'),
(27, 9, 'Celle qui est à côté de l''ascenseur est moins chère que les autres', 'The one which is next to the lift is less expensive than the others'),
(27, 10, 'mais je parie qu''elle est plus bruyante.', 'but I bet that it''s noisier (more noisy).'),
(27, 11, 'Celles au rez-de-chaussée sont petites, à mon avis', 'Those on the ground floor are really small, in my opinion (at my advice)'),
(27, 12, 'mais les équipements sont identiques à ceux des chambres supérieures', 'but the facilities are identical to those of the superior rooms.'),
(27, 13, 'et les tarifs ne sont pas les mêmes. C''est beaucoup moins cher.', 'and the rates (tariffs) are not the same. It''s much less expensive.'),
(27, 14, 'Est-ce qu''il y a des chambres disponibles pour le vendredi soir ?', 'Are there [any] rooms available for the Friday night (evening)?'),
(27, 15, 'Mince alors! Tout est complet. Je vais regarder le deuxième hôtel.', 'Drat (thin then)! Everything is full. I''ll look at the second hotel.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(25, 1, 'We know that the second person singular and plural are used in the imperative (lesson 16 note 3). The same is true of the first person plural: **Déjeunons**, *Let''s have lunch* **Faisons vite**, *Let''s make it fast*. (Remember that the final -s is silent.) See lesson 18.', 1),
(25, 2, 'Most French words come from either Latin or Greek, whereas at least a third of English words are of Anglo-Saxon origin Which means that one French word can often be translated in two ways. For example, **accompagner** is either *to accompany* or *to go/come with*. For many English speakers, used to short phrasal verbs, French can sound very formal. It takes time to get used to this "double" vocabulary, so let''s start now!', 2),
(25, 3, 'Don''t confuse **un quartier**, *a district or neighbourhood of a city* (lesson 21) with **un quart**, *a quarter*. The noun can also be used attributively: **un restaurant de quartier**, *a neighbourhood restaurant*. (It is also used to refer to a segment of fruit or a cut of meat.)', 3),
(25, 4, '**lequel** (masc.), **laquelle** (fem.) and **lesquels/lesquelles** (plu.) are pronouns formed by combining the definite articles **le/la/les** and the interrogative adjectives **quel/quelle/quels/quelles**, meaning *which/what*. In this lesson and lesson 22, they are used as interrogatives. **J''aime ces trois restaurants. - Lequel est-ce que vous préférez ?** *I like these three restaurants - Which one do you prefer?*. **Nous cherchons la crêperie - Laquelle ?** *- We''re looking for the pancake house. - Which one?* We will see later how to use these compounds as pronouns.', 5),
(25, 5, 'An idiom is an expression whose meaning can''t be guessed from its various parts. For example, **Ça m''est égal** ("It to me is equal") is equivalent to *it''s all the same to me* or *I don''t mind*. Similarly, the interrogative **Ça vous dit?** (literally "that you speaks") means something like *Do you fancy that?* Remember to make a special note of idioms and expressions whenever you come across them, because the meaning is not always obvious.', 6),
(25, 6, 'The adjective **droit** has two meanings: *right* (the opposite of **gauche**, *left*) and *straight*. **Le genou droit**, *the right knee*, **un chemin droit**, *a straight path*. Of course, both adjectives agree with their nouns: **l''épaule droite**, *the right shoulder*, **deux lignes droites**, *two straight lines*. The expression **tout droit**, *straight ahead*, is an adverb and therefore invariable.', 11),
(25, 7, '**venir de**, *to come from*, followed by an infinitive, is an idiomatic way to express the immediate past. It is the translation of *to have just + past participle* in English: **Je viens de voir Elsa**, *I''ve just seen Elsa*. The expression is not used in the negative and is rarely found in the interrogative.', 12),

(26, 1, 'The verb **suivre**, *to follow*, is the root of **la suite**, *the continuation* (i.e. that which follows). The expression **Si vous voulez bien me suivre** is a formal way of asking someone to follow you. In a less formal setting, the server might say **Suivez-moi** (*Follow me*) as they lead you to your table. It''s important to recognise the register, or level of formality, that is being used in order to respond accordingly.', 2),
(26, 2, '**convenir** is another rather formal verb, meaning *to suit, to be convenient/suitable for*, etc. For the time being, just remember the interrogative expression **Est-ce que ça vous convient ?**, *Does that suit you?* or, more idiomatically, *Is that okay with you?* And the response **Ça me convient / Ça ne me convient pas**, *That''s fine / That doesn''t suit me*. Remember that idiomatic phrases can be translated in different ways, depending in the context, but the basic meaning is the same.', 2),
(26, 3, 'As we know, the verb **avoir** is used with several expressions whose English equivalents are formed with *to be* (**J''ai trente ans**, *I am thirty*). Similar constructions include **avoir faim**, *to be hungry* (lesson 25), **avoir soif**, *to be thirsty*, **avoir chaud**, *to be hot*, and **avoir froid**, *to be cold*.', 3),
(26, 4, 'Remember that the present simple tense in French can express an immediate future (see lesson 10 note 4). **Je vous apporte la carte**, *I''ll bring you the menu*.', 4),
(26, 5, 'We saw in note 1 that **la suite**, from **suivre**, *to follow*, means *a continuation*. But **tout de suite** is an idiomatic expression meaning *immediately, at once*. **Faites-le tout de suite**, *Do it straight away*. Note the pronunciation [toot-sweet].', 5),
(26, 6, 'In the previous lesson we learned a group of compound pronouns (**lequel**, etc.). The root word is the interrogative adjective **quel**, *what* or, when used discriminatively, *which*, and its feminine and plural forms: **quel plat...?**, *which dish*, **quelle carte...?**, *which card/menu*, **quels légumes...?**, *which vegetables...?*, **quelles tables...?**, *which tables...?* All four adjectives are pronounced identically [kel] unless the following noun starts with a vowel, in which case the two are liaised: **quelles églises** [kelzaygleez].', 6),
(26, 7, '**le sang** (pron. [sœh"]), *blood*, is the root of the verb **saigner**, *to bleed*, and the adjective **saignant** (fem. **saignante**) which literally means *bleeding* but, when applied to a steak, signifies *rare*.', 11),
(26, 8, '**une addition**, literally "an addition," also means *a bill* in the context of food service. **L''addition, s''il vous plaît**. *The bill, please*. A common synonym is **la note** (pron. [not]). The word for an invoice is **une facture**.', 14),

(27, 1, 'Be careful of the verb **voler**, which means *to fly* but also *to steal*. Thus **un vol** means either *a flight* or *a theft*, but hopefully the context will make the meaning clear!', 2),
(27, 2, 'In the transitive form, **rater** means *to miss (a flight, an opportunity, etc.)* **Ne ratez pas votre avion!** *Don''t miss your plane!* It does not, however, have the same emotional connotation of loss or absence as the English verb. For this we use another verb, **manquer**, which we will see later on.', 2),
(27, 3, 'The pronouns **celui** (masc. sing), **celle** (fem. sing.), **ceux** (masc. plur., see lesson 23) and **celles** (fem. plur.) are similar to *the one/the ones* (or *those*) in English, and perform the same function of avoiding the repetition of a noun. **Il y a deux hôtels: celui près de l''aéroport est cher.** *There are two hotels: the one near the airport is expensive.*', 6),
(27, 4, '**un avis** (note the pronunciation: [ahnavee / ahnavee]) shares the same root as the English word advice (a credit or debit advice from a bank is **un avis de débit/crédit**). But the most common meaning is *an opinion*: **Donnez-nous votre avis**, *Give us your opinion*. The word is frequently used in expressions with the possessive adjectives: **à mon avis**, *in my opinion*, **à son avis**, *in his or her opinion*, etc. The plural is the same as the singular: **Les avis sont partagés**, *Opinions are divided*.', 11),
(27, 5, 'As we saw in lesson 15 note 6, some nouns are singular in English but plural in French, and vice versa. The collective masculine noun **l''équipement** means *equipment*, but, when used in the plural, **les équipements** has a much broader meaning, similar to *facilities* or *amenities*.', 12);

INSERT INTO contents (course_id, seq, french, english) VALUES
(29, 1, 'Salut, Louis! Comment vas-tu ?', 'Hi, Louis! How are you?'),
(29, 2, 'Je vais très bien. Et toi, Manon? La forme ?', 'I''m very well. And you, Manon? On [good] form?'),
(29, 3, 'Ça va, merci. Qu''est-ce que tu fais ici ?', 'Fine thanks. What are you doing here?'),
(29, 4, 'Mes courses. Je cherche une pâtisserie pour acheter une tarte ou un gâteau.', 'My shopping. I''m looking for a cake shop to buy a tart or a cake.'),
(29, 5, 'Les Mercier viennent dîner ce soir et je sais que Clément adore les pâtisseries.', 'The Merciers are coming [to] dinner this evening and I know that Clément loves pastries.'),
(29, 6, 'Je dois aussi trouver un cadeau à leur offrir', 'I also have to find a present to give (offer) them'),
(29, 7, 'parce que c''est leur anniversaire de mariage samedi prochain.', 'because it''s their wedding anniversary next Saturday.'),
(29, 8, 'Mais je n''ai pas d''idées précises. Je ne connais pas leurs goûts.', 'But I don''t have any precise ideas. I don''t know their tastes.'),
(29, 9, 'Est-ce que tu sais où je peux acheter quelque chose d''original ?', 'Do you know where I can buy something (of) original?'),
(29, 10, 'Il y a un centre commercial là-bas, près du bureau de poste. Tu le vois ?', 'There''s a shopping (commercial) centre over there, near (to) the post office.'),
(29, 11, 'Dedans, tu as une superbe pâtisserie qui vend des tartes délicieuses pour le dessert,', 'Inside, there''s (you have) a superb cake shop that sells delicious tarts for (the) dessert'),
(29, 12, 'et des gâteaux délicieux avec des noix, des morceaux de chocolat et de la chantilly.', 'and delicious cakes with walnuts, bits of chocolate and whipped cream.'),
(29, 13, 'Excellente idée ! Je sais que nos amis sont très gourmands.', 'Excellent idea! I know that our friends are very fond of food.'),
(29, 14, 'Et pour le cadeau, qu''est-ce que tu penses d''un tableau ?', 'And for the present, what do you think of a painting?'),
(29, 15, 'Plutôt des tisanes, pour faciliter la digestion!', 'Herb teas instead, to help [with] digestion.'),

(30, 1, 'Excuse-moi un instant, Juliette. Je dois répondre au téléphone.', 'Excuse me a second (instant), Juliette. I have to answer the phone.'),
(30, 2, 'Allô ? Ah, c''est toi, Antoine. Je t''entends très mal.', 'Hello? Ah, it''s you Antoine. I can''t hear you very well ( hear you very badly).'),
(30, 3, 'Je perds le signal. Attends, ne quitte pas.', 'I''m losing the signal. Wait, don''t hang up (leave).'),
(30, 4, 'Reste où tu es. Je vais descendre au premier étage.', 'Stay where you are. I''m going to go down to the first floor.'),
(30, 5, 'Tu sais que nous sommes au milieu de la campagne, sans antenne de téléphone !', 'You know that we''re in the middle of the countryside, without [a] telephone aerial!'),
(30, 6, 'Voilà: est-ce que tu entends ma voix ? Je mets le haut-parleur.', 'There: can (isit that) you hear my voice? I''m putting [on] the loud-(high)speaker.'),
(30, 7, 'Oui, c''est bien. J''ai un truc à te demander, Stéphane.', 'Yes, that''s fine. I''ve got something (a thing) to ask you, Stéphane.'),
(30, 8, 'Vas-y. Qu''est-ce que je peux faire pour toi ?', 'Go ahead (go there). What can I do for you?'),
(30, 9, 'Peux-tu me prêter ton aspirateur ? J''en ai besoin pour nettoyer ma piscine.', 'Can you lend me your vacuum cleaner to clean my swimming pool?'),
(30, 10, 'Le magasin dans notre village n''en vend pas.', 'The shop in our village doesn''t (of them) sell [them].'),
(30, 11, 'Je promets de ne pas le perdre! Tu peux me faire confiance.', 'I promise not to lose it! You can trust me (make me confidence).'),
(30, 12, 'Écoute, je veux bien mais ça ne dépend pas entièrement de moi.', 'Listen, I''m fine with that (want well) but it doesn''t depend entirely on me.'),
(30, 13, 'Je vais demander à Juliette si elle en a besoin. [...]', 'I''ll go [and] ask (to) Juliette if she (of it) needs [it]. [...]'),
(30, 14, 'Bon, c''est d''accord si tu nous le rends avant la fin de la semaine.', 'Well (good), she agrees (it''s okay) if you return it [to] us before the end of the week.'),
(30, 15, 'Merci. Je te le rends après-demain. À tout à l''heure .', 'Thanks. I [will] give it back [to] you [the day] after tomorrow. See you later (to all to the-hour).'),

(31, 1, 'Que puis-je faire pour vous, madame ?', 'What might I do for you, madam?'),
(31, 2, 'Est-ce que vous avez des bouilloires électriques ?', 'Do you have electric kettles.'),
(31, 3, 'J''en ai deux: celle-ci, à moins de cent euros,', 'I (of them) have two: this one here, at less than a hundred euros,'),
(31, 4, 'et celle-là, qui est à quatre cents euros.', 'and that one there, which is for ( ) four hundred euros.'),
(31, 5, 'Mais c''est hors de prix ! Elle est en argent ?', 'But that''s outrageous (out of price). Is it made of (in) silver?'),
(31, 6, 'Bien sûr que non. C''est un appareil très sophistiqué: il est même connecté à Internet !', 'Of course not. It''s a very sophisticated appliance: it''s even connected to [the] Internet.'),
(31, 7, 'Tout le monde en parle, et j''en vends beaucoup.', 'Everyone is talking about them, and I sell a lot of them.'),
(31, 8, 'Mais celle à cent euros marche très bien aussi, je vous assure.', 'But the one for (at) a hundred euros works very well, too, I assure you.'),
(31, 9, 'Est-ce que vous en êtes sûr ?', 'Are you sure of that?'),
(31, 10, 'Oui, j''en suis certain. Tous mes clients en sont contents, enfin, presque tous...', 'Yes, I''m certain of it. All my customers (of-it) are happy, well (at last) almost all...'),
(31, 11, 'Bon, d''accord. Donnez-moi celle à quatre cents.', 'Okay, alright. Give me the one for four hundred.'),
(31, 12, 'Excellent choix. Je regarde sur mon ordinateur...', 'Excellent choice. I''m checking (looking on my computer...'),
(31, 13, 'Ah, excusez-moi: nous n''en avons plus.', 'Ah, excuse me: we don''t have any more (not-of-it have more).'),
(31, 14, 'Vous en avez besoin aujourd''hui ? Sinon, je peux en commander une pour demain.', 'You need one today? If not, I can (of it) order one for tomorrow.'),
(31, 15, 'Non, j''en ai vraiment besoin rapidement. Tant pis. Merci pour votre aide.', 'No, I really it need it quickly. Never mind. Thanks for your help.'),
(31, 16, 'Je vous en prie. Merci de votre visite.', 'You''re welcome (I you ofit pray). Thanks for visiting.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(29, 1, '**Salut!** (the origin of salute) is a familiar greeting, equivalent to *Hi!* As a singular noun, **un salut** is either a wave (of the hand) or a nod (of the head).', 1),
(29, 2, '**tu** is the familiar pronoun for the singular *you*. It is used when talking to friends, family members and children. **Toi**, in this context, is the object pronoun.', 2),
(29, 3, '**la forme**, meaning the form or shape, is also used to refer to fitness or health, as we saw in lesson 24. **Louis est en forme aujourd''hui**, *Louis is on top form today*. The polite expression **J''espère que tu es en forme?**: *I hope you''re doing well?* is often shortened to just **La forme ?**, with a rising intonation, in familiar contexts.', 2),
(29, 4, 'You should be familiar with the two meanings of **les courses**, *errands, shopping* (lesson 13) and *horse races* (lesson 22). Similarly, **un anniversaire** can mean both a *birthday* and an *anniversary*. Remember to take special note of these homonyms, which can often be disconcerting.', 4),
(29, 5, 'Unlike English, French surnames do not take an -s in the plural: **Monsieur et Madame Mercier** -> **Les Mercier**. Of course, this does not affect the pronunciation.', 5),
(29, 6, '**une pâtisserie** refers to both a *pastry* (the circumflex replacing the letter s) and the shop in which it is bought.', 5),
(29, 7, '**offrir**, *to offer*, can also mean *to give* when used in the context of a gift. **J''offre souvent des cadeaux à mes enfants**, *I often give my children presents*. See also note 9.', 6),
(29, 8, 'See lesson 13 note 6 and lesson 35 for more about the difference between **savoir** and **connaître**.', 8),
(29, 9, 'Singular nouns ending in **-eau** form their plural with a (silent) final **x**. They include **un cadeau** (*a gift*), **un bureau** (*an office*), **un morceau** (*a piece, a bit, a slice*), **un gâteau** (*a cake*) and **un tableau** (*a painting*).', 14),
(29, 10, 'The adverb **plutôt**, *rather, instead*, is a useful way of qualifying a statement or expressing a preference: **Je n''aime pas les tartes, je préfère plutôt les gâteaux**, *I don''t like tarts, I prefer cakes instead*.', 15),

(30, 1, '**un truc** is a familiar but very common placeholder word meaning *a thing, a whatname*, etc.', 7),
(30, 2, '**Allô** comes from the English hello and, in France, is used only when answering the phone (in Quebec, it is also a greeting, like *Hi!*). The word is often found in the business names of emergency call-out services, such as *Allô Serrurier* for a 24/7 locksmith.', 2),
(30, 3, '**entendre**, *to hear*, along with **vendre** (lesson 29) and several other verbs in this lesson, provide an introduction to Group Three, which comprises three types of endings divided into sub-categories. Verbs in the first sub-category end in **-re**. The inflexions are **j''entends, tu entends, il/elle entend, nous entendons, vous entendez, ils entendent**. Note that the -s is usually dropped from the second person singular in the imperative form (but see note 5).', 2),
(30, 4, '**quitter**, *to leave*, is the origin of the verb to quit. **Quittez l''autoroute à la sortie trente**, *Leave the motorway at exit 30*. On the telephone, **Ne quittez pas**, or **Ne quitte pas** in the familiar form, means *Please hold* ("Don''t leave").', 3),
(30, 5, '**mettre**, *to put*, is an important verb (**je mets, tu mets, il/elle met, nous mettons, vous mettez, ils mettent**). Unlike English, it does not usually take a preposition (**mettre un manteau**, *to put on a coat*).', 6),
(30, 6, '**Vas-y** is the familiar form of **Allez-y**, *Go ahead* (lesson 12 note 2). The terminal -s is retained in the imperative before the adverbial pronouns **y** and **en** to make pronunciation easier ([vahzee]).', 8),
(30, 7, '**vouloir bien** (literally "to wish well") is used in polite expressions like **Je veux bien** or **Si vous voulez / tu veux bien** to express acceptance (similar to the formal *If you will* in English).', 12),
(30, 8, 'Used with the present or future tenses, the adverbial phrase **à tout à l''heure** ("to all to the hour") is equivalent to *later on* or, as a valediction, *See you later*. It can also be used with a past tense, meaning *earlier*. (The phrase is probably the origin of the English slang term toodle-oo.)', 15),

(31, 1, 'We came across **puis-je** in the exercises in lesson 26. The term, derived from the old interrogative form of **je peux**, *I can*, is now used only in polite, formal questions, like may/might in English: **Puis-je avoir votre nom?** *Might I have your name?*; **Que puis-je faire pour vous?** *What may I do for you?* (**Puis-je** cannot be used in questions formed with **est-ce que...?**, which, by definition, are less formal than the inverted interrogative).', 1),
(31, 2, 'The adverbial pronoun **en** was introduced in the previous lesson. It has several functions, notably to avoid repetition of a noun. **En** is frequently used with the partitives **du/de la/des**: **J''ai du café. Vous en voulez ?** / *have coffee. Do you want some?* See also note 5.', 2),
(31, 3, 'The demonstrative pronouns **celui / celle / ceux / celles** (lesson 28) can''t be used on their own (**Les tartes ? J''aime celles aux fraises**). But they can take the suffixes **-ci** (here, an abbreviation of **ici**, which has no cedilla under the c) and **-là** when indicating (or "demonstrating") a specific thing that is either close to or distant from the speaker: **Tu veux celui-ci ?**, *Do you want this one [here]?* **Nous préférons celles-là**, *We prefer those ones [over there]*.', 3),
(31, 4, '**hors** means *out of, away from*. Followed by **de**, it is a prepositional phrase: **Il est hors du bureau pour le moment**, *He''s out of the office for the moment*. It can also be used in set expressions such as **hors de question** (see lesson 18), **hors de prix** ("out of price"), *overpriced or outrageously expensive*, as well as the culinary term **hors d''œuvre**, ("out of work"), *a starter*.', 5),
(31, 5, '**en** is also a preposition meaning *in*. It can be used in phrases indicating either a state—**en or**, *in/of gold*—or a situation, **en vacances**, *on holiday*. For the time being, simply memorise the phrases you come across. We''ll learn more as we go along.', 5),
(31, 6, 'We know that **l''argent** means *money*, but the other meaning is *silver*. In this case, it is preceded by **de** (**la médaille d''argent**, *the silver medal*) or **en**: **Ma nouvelle montre est en argent**, *My new watch is in silver*.', 5),
(31, 7, 'Don''t confuse the preposition **sur**, *on*, with the adjective **sûr**, *safe, secure*. Both words (and the feminine adjective **sûre**) are pronounced identically, but the circumflex on the second word makes it easier to tell the difference between them.', 9),
(31, 8, '**tant pis** is a set expression meaning *Too bad* or *Never mind*. (Pis a literary form of pire, worse/worst, which we will see shortly).', 15),
(31, 9, '**Je vous en prie** is the standard response to **Merci**, *Thank you*. The familiar (tu) form is **Je t''en prie**. Although the literal translation, "I pray you," is very formal (and rarely used) in English, the French expression—both the vous and the tu forms—is standard.', 16);

INSERT INTO contents (course_id, seq, french, english) VALUES
(32, 1, 'Pourquoi est-ce que vous êtes si fatigué quand vous rentrez chez vous le soir ?', 'Why are you so tired when you go home [in] the evening?'),
(32, 2, 'Mon travail est vraiment épuisant, vous savez.', 'My job (work) is really exhausting, you know.'),
(32, 3, 'Je suis responsable d''une équipe d''une dizaine de personnes', 'I''m responsible for a team of around ten people'),
(32, 4, 'dans le service commercial d''une petite entreprise, Gagner Plus.', 'in the marketing department of a small company (enterprise), Gagner Plus (Earn More).'),
(32, 5, 'Je connais cette société. Qu''est-ce que vous y faites ?', 'I know that company. What do you do there (there-do)?'),
(32, 6, 'Nous répondons aux mails des clients: nous en recevons des centaines chaque jour.', 'We answer (to) emails from customers: we (of-therm) receive hundreds each day.'),
(32, 7, 'En principe, nous devons les lire systématiquement, mais ce n''est pas toujours possible.', 'In principle, we must read them systematically, but it''s not always possible.'),
(32, 8, 'Bien sûr, nous ne pouvons pas répondre à chacun d''entre eux, même si nous faisons de notre mieux.', 'Of course, we can''t answer each one (among them), even if we do (of) our best.'),
(32, 9, 'Nous savons que nous faisons quelque chose de très important.', 'We know that we are doing something (of) very important.'),
(32, 10, 'Je ne refuse jamais d''aider mes collègues : je jette un coup d''œil à leur travail', 'I never refuse to help my colleagues: I glance (throw a blow of eye) at their work'),
(32, 11, 'et je leur donne un coup de main quand je peux.', 'and I give them a (blow of) hand when I can.'),
(32, 12, 'À la fin de la journée, j''ai mal aux yeux et souvent des maux de tête.', 'At the end of the day, I have sore eyes and often headaches.'),
(32, 13, 'Je ne peux plus regarder la télé, même quand il y a quelque chose qui me plaît.', 'I can no longer watch the TV, even when there is something that I like (me pleases).'),
(32, 14, 'Demain je vais voir le directeur et lui dire que je ne peux plus continuer comme ça.', 'Tomorrow I''m going to see the director and tell (say to) him that I can no longer continue like this.'),
(32, 15, 'Ah, vous n''êtes pas au courant ? Vous ne pouvez plus lui parler:', 'Ah, aren''t you aware (you aren''t at current)? You can no longer talk to him:'),
(32, 16, 'il vient de démissionner - à cause de la fatigue.', 'he''s just resigned -because of tiredness.'),

(33, 1, 'Ah, c''est toi, Margot. Entre et assieds-toi.', 'Ah, it''s you, Margot. Come in and sit (you) down.'),
(33, 2, 'Je ne vous dérange pas ? Je peux revenir si vous voulez.', 'I''m not disturbing (deranging) you [am I]? I can come back if you want.'),
(33, 3, 'Tu ne nous déranges pas du tout. Qu''est-ce que tu veux ?', 'You''re not disturbing us at all. What do you want?'),
(33, 4, 'J''ai besoin d''une nouvelle robe d''été: aidez-moi à la choisir.', 'I need a new summer dress: help me to choose it.'),
(33, 5, 'Tu en as besoin, ou tu en as envie ? Ce n''est pas la même chose !', 'You need one or you want one? It''s not the same thing!'),
(33, 6, 'Je sais bien, mais quelle importance ? Je veux en acheter une.', 'I know [very] well, but what does it matter (what importance)? I want to buy one.'),
(33, 7, 'Je n''ai rien dans ma garde-robe. Tous mes vêtements sont vieux.', 'I have nothing in my wardrobe. All my clothes are old.'),
(33, 8, 'Bien, regardons en ligne. Tu connais ce site, mode.fr ?', 'Well, let''s look online. Do you know this site, mode.fr (fashion.fr)?'),
(33, 9, '"Choisissez parmi des milliers de modèles pour trouver le vêtement de vos rêves".', '"Choose among thousands of models to find the [item of] clothing of your dreams."'),
(33, 10, 'C''est génial. Tu trouves tout: des robes, des jupes, des pulls, des manteaux.', 'It''s fantastic. You [can] find everything: dresses, skirts, jumpers, coats.'),
(33, 11, 'Ce n''est pas vraiment bon marché mais les prix sont raisonnables.', 'It''s not really cheap (good-market) but the prices are reasonable.'),
(33, 12, 'Regarde ce chemisier est joli, n''est-ce pas ? II existe en rouge, en bleu et en orange.', 'Look: this blouse is pretty, isn''t it? It comes in (ensts) in red, blue, and orange.'),
(33, 13, 'Je cherche une robe verte, noire ou bleue , pas un chemisier orange ou jaune !', 'I''m looking for a green, black or blue dress, not an orange or yellow blouse!'),
(33, 14, 'Et celle-là? Qu''est-ce que tu en penses ? C''est très chic.', 'And this one? What do you think (of it)? It''s very stylish.'),
(33, 15, 'Non, je ne vois rien qui m''intéresse. Mais merci quand même ! À demain.', 'No, I can''t see anything that interests me. But thank you all the (even) same! See you (to) tomorrow.'),

(34, 1, 'Je ne cours plus parce que j''ai trop mal aux genoux - je souffre énormément,', 'I don''t run anymore because my knees hurt too much (too bad to the knees) - I''m in great pain (suffer enormously),'),
(34, 2, 'mais je ne peux pas rester sans rien faire.', 'but I can''t stay here without doing anything.'),
(34, 3, 'Cette année, je fais une marche de soixante-dix kilomètres', 'This year, I''m doing a 70 km walk'),
(34, 4, 'entre les villes de Colmar et Strasbourg, en Alsace.', 'between the cities of Colmar and Strasbourg, in Alsace.'),
(34, 5, 'Je pars bien avant le soleil de midi, et j''arrive le lendemain vers vingt heures.', 'I leave well before the noon sun, and I arrive the following day around 8pm.'),
(34, 6, 'Je m''arrête à mi-chemin, près de Sélestat, pour manger et dormir.', 'I stop halfway (half path), near Sélestat, to eat and sleep.'),
(34, 7, 'J''y passe la nuit et repars après le petit-déjeuner.', 'I spend the night there and leave again after breakfast.'),
(34, 8, 'Vous faites cette randonnée tout seul, ou avec d''autres gens ?', 'Are you doing this hike (all) alone, or with other people?'),
(34, 9, 'Avec des copains. Ils l''organisent quatre fois par an, y compris en automne et en hiver.', 'With [some mates. They organise it four times a (by) year, including in autumn and winter.'),
(34, 10, 'Le temps est souvent pluvieux et il peut faire très froid, mais ce n''est pas grave.', 'The weather is often rainy and it can be (make) very cold, but it doesn''t matter (is not serious).'),
(34, 11, 'Tu veux dire qu''il pleut ou il neige tout le temps? Moi, je ne mets pas le nez dehors.', 'You mean (want to say) that it rains or it snows all the time! Me, I never go (put the nose outside.'),
(34, 12, 'Oui, mais la pluie ne me gêne pas, et je ne sens pas le froid.', 'Yes, but the rain doesn''t bother me, and I don''t feel the cold.'),
(34, 13, 'Moi, mon moment préféré, c''est l''arrivée. On va tout de suite au café.', '[For] me, my favourite moment is the arrival. We go straight away to the café.'),
(34, 14, 'Le patron ouvre la porte et nous dit:', 'The boss opens the door and says [to] us:'),
(34, 15, '"C''est moi qui offre la tournée: qu''est-ce que je vous sers?"', '"It''s my round (it''s me who offers the round : what can I get (serve) you?".');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(32, 1, 'As we know, **si** means *if*, but it can also be an intensifier, like *so*. **Ma collègue est si fatiguée qu''elle ne peut plus continuer**, *My colleague is so tired that she can''t continue*.', 1),
(32, 2, 'This lesson looks at the second sub-category of third-group verbs: those ending in **-oir**: **devoir**, *to have to / must*, **pouvoir**, *to be able to / can*, **recevoir**, *to receive*, **savoir**, *to know*, and **voir**, *to see*. You have already come across most of them, but now you can see that they are conjugated in the same way.', 2),
(32, 3, 'Just like **une dizaine**, *approximately ten* (lesson 19 note 3), **une centaine** means *about a hundred*. The indefinite plural can be used in the same way as hundreds in English: **Je reçois des centaines de mails d''une dizaine de collègues**, *I receive hundreds of emails from ten or so colleagues*.', 3),
(32, 4, 'The indefinite pronouns **chacun** (masculine) and **chacune** (feminine) are compounds of **chaque** plus **un/une**: *each one*. **Je regarde chacun des mails en détail**, *I look at each email (or, alternatively, each one of these emails) in detail*. For emphasis, the pronoun can be placed at the end of the phrase, as in English: **Ces bouilloires coûtent cent euros chacune**, *These kettles costs 100 euros each*. Don''t confuse **chacun(e)** with **chaque**, which is followed by a noun: **Chaque appareil coûte cent euros**, *Each device costs 100 euros*. Obviously, neither **chacun(e)** nor **chaque** has a plural form.', 8),
(32, 5, 'The negative verb form is usually constructed with **ne... pas**. In some cases, however, **pas** can be replaced with an adverb, notably **jamais** and **plus**. **Il ne répond jamais au téléphone**, *He never answers the phone*, **Elle ne répond plus à mes messages**, *She is no longer answering my messages*.', 10),
(32, 6, 'Another very common irregular plural is the masculine noun for the eye, **l''œil**, which becomes **les yeux** (pronounced yeu). Note also the idiom **un coup d''œil**, *a glance*, used with the verb **jeter**, *to throw*. (The expression **donner un coup de main**, used in line 11, is equivalent to the English idiom to give someone a hand.)', 10),
(32, 7, 'The indirect object pronouns are **me, te, lui, nous, vous** and **leur**. **Max nous donne un coup de main**, *Max is giving us a hand*. **Peux-tu me prêter dix euros?** *Can you lend me ten euros?* They are identical to the direct object pronouns, except for the third persons singular and plural: **lui** and **leur**. Note that the singular **lui** can mean him or her. **Je lui donne un cadeau** *I''m giving him OR her a present*. Last, don''t confuse the pronoun **leur** with the possessive adjective, spelled identically **leur travail**, *their work*.', 11),
(32, 8, 'The plural of **un mal**, *a pain, an ache*, is **des maux**. See lesson 24 note 3.', 12),

(33, 1, 'Here is another example of the lexical links between French and English. Over the centuries, **une garde-robe** (plural **garde-robes**), literally "keep dress", evolved into a *wardrobe*.', 7),
(33, 2, 'Remember that the second person singular imperative of -er verbs has no final -s (**tu entres -> Entre!** *you come in -> Come in!*). However, for all regular and most irregular -ir and -re verbs, the imperative is identical to the indicative **tu attends -> Attends!**', 1),
(33, 3, 'When used with the imperative, the direct object pronouns **me** and **te** become **-moi** and **-toi**: **vous me donnez la clé -> Donnez-moi la clé !** **tu t''assieds -> Assieds-toi!**', 1),
(33, 4, 'We saw **pas du tout**, *not at all*, used on its own (lesson 3) as an emphatic negative. The phrase can also be used after a verb: **Je ne les connais pas du tout**, *I don''t know them at all*.', 3),
(33, 5, 'Here is another negative construction formed with **ne** and an adverb (see lesson 32 note 5), in this case **rien**: **Je n''ai rien à faire à la maison**, *I have nothing to do at home*, **Il ne voit rien la nuit**, *He can''t see anything at night*. Remember that **pas** is not used in this type of construction, otherwise it would create a double negative.', 7),
(33, 6, 'This is another example of a word that can be singular in French but not in English (lesson 27 note 5): **les vêtements** means *clothes* (**Ses vêtements sont chics**, *His/her clothes are smart*) whereas **un vêtement** is an *item of clothing*. **Ce vêtement est trop petit**, *This piece of clothing is too small*. In practice, we would generally use another, more precise word in English (this coat, etc.) but **un vêtement** is standard French.', 7),
(33, 7, '**mille** is a *thousand* so **un millier** is *approximately a thousand*, just like **dix/une dizaine** (lesson 19 note 3) and **cent/ une centaine** (lesson 32 note 3). It, too, has a plural form **Des milliers de gens**, *Thousands of people*. And it''s masculine, not feminine.', 9),
(33, 8, 'The compound adjective **bon marché** ("good market") means *inexpensive, cheap* (with no negative connotation). It is invariable: **Voici une liste des hôtels bon marché à Bordeaux**, *Here''s a list of inexpensive hotels in Bordeaux*. A synonym is **pas cher**, *not expensive*, but in this case, the adjective agrees: **des hôtels pas chers**.', 11),
(33, 9, 'When used as adjectives, colours generally agree with the noun in number and gender: **un manteau bleu**, *a blue coat*, **des jupes bleues**, *blue skirts*. Of course, if the masculine adjective ends in -e, it does not change: **un pull jaune**, **une robe jaune**.', 13),

(34, 1, 'This is final sub-category of third-group verbs which end in **-ir** but are irregular (unlike Group 2 verbs). They include **courir**, *to run*, **dormir**, *to sleep*, **sentir**, *to feel*; **servir**, *to serve*; **ouvrir**, *to open*, **souffrir**, *to suffer*, **offrir**, *to offer* (see lesson 29 note 7); and **servir**, *to serve*. The endings are, for example, **je cours, tu cours, il/elle court, nous courons, vous courez, ils/elles courent**.', 5),
(34, 2, 'Normally, the plural of nouns ending in **-ou** is formed by adding an s (**un trou**, *a hole*, **des trous**). But a handful, including **un genou**, *a knee*, **un bijou**, *a jewel*, and **un caillou**, *a pebble*, take an x. There are seven of these nouns in all, but these three are the most common.', 1),
(34, 3, '**rien** can mean both *anything* or *nothing* (lesson 33 note 5). Note the place of this pronoun, which, unlike English, comes before the verb: **II ne peut rien faire pour toi**, *He can''t do anything for you*.', 2),
(34, 4, '**mi-** is a shortened form of **demi**, *half*. It is used in a number of expressions, notably **à mi-chemin** ("half-path"), *halfway*: **Sélestat est à mi-chemin entre Colmar et Strasbourg**, *Sélestat is halfway between Colmar and Strasbourg*.', 6),
(34, 5, 'We know that the adverb **y** means *there*, as in **il y a**. But it can also be used to avoid repeating a noun, just like **en** (lesson 31 note 2). **Tu connais Colmar ? J''y habite**, *Do you know Colmar? - I live there* (instead of **J''habite à Colmar**). Like **rien** (note 3), **y** comes before the verb, It can also be used in the expression **y compris**, *including*. **Toute la famille est invitée, y compris ton frère**, *The whole family is invited, including your brother*. In this case, **y** has no intrinsic meaning.', 7),
(34, 6, 'Here''s another very common vernacular word **un copain** (feminine **une copine**) means *a pal, a mate*. Depending on the context, the term can be used for a boyfriend/girlfriend. **Le copain de Noémie est un artiste qui s''appelle Florian**, *Noémie''s boyfriend is an artist called Florian*.', 9),
(34, 7, 'Like **une course** (lesson 29 note 4), **le temps** has two meanings: the *time* and the *weather* (despite the final s, the word is singular). The context should make it easy to tell the difference, but remember this mnemonic just in case: **Je n''ai pas le temps pour ce mauvais temps**, *I don''t have time for this bad weather* (**Un temps** can also mean a (verb) *tense*: **Le futur simple est un temps de l''indicatif**, *The future simple is an indicative tense*-see lesson 8 note 3).', 10);

INSERT INTO contents (course_id, seq, french, english) VALUES
(36, 1, 'Ça y est. J''ai commandé le taxi. On peut partir à l''aéroport dans cinq minutes.', 'Here we go. I''ve ordered the taxi. We can leave for (to) the airport in five minutes.'),
(36, 2, 'Est-ce que tu as fermé toutes les fenêtres et tous les volets ?', 'Have you closed all the windows and all the shutters?'),
(36, 3, 'Oui, j''ai tout vérifié, même le grenier. Tout est verrouillé.', 'Yes, I''ve checked everything, even the attic. Everything is bolted.'),
(36, 4, 'J''ai vidé le réfrigérateur et le congélateur tout à l''heure', 'I''ve emptied the refrigerator and the freezer just now'),
(36, 5, 'et j''ai fermé la porte de la cave.', 'and I''ve closed the door of the cellar.'),
(36, 6, 'Est-ce que tu as vidé les poubelles de la cuisine et la salle de bains ?', 'Have you emptied the rubbish bins in the kitchen and the bathroom?'),
(36, 7, 'Mais oui! Et la corbeille à papier. Ne t''inquiète pas.', '(Bur) yes [I have]! And the [waste]paper basket. Don''t worry!'),
(36, 8, 'Est-ce que tu as caché mes bagues et mes colliers ?', 'Have you hidden my rings and my necklaces?'),
(36, 9, 'J''ai fait tout ce que tu m''as demandé.', 'I have done everything that you asked me.'),
(36, 10, 'Hier, j''ai fait aussi des copies de nos passeports et déposé tout sur notre coffre en ligne.', 'Yesterday I''ve also made copies of our passports and deposited the copies on our online safe (trunk).'),
(36, 11, 'J''ai demandé à notre voisine de vérifier notre boîte à lettres et de la vider de temps en temps.', 'I''ve asked our [female] neighbour to check our letter box and to empty it from time to time.'),
(36, 12, 'Moi, j''ai changé les draps, nettoyé la cuisine et lavé la vaisselle.', '[As for] me, I''ve changed the sheets, cleaned the kitchen and washed the dishes.'),
(36, 13, 'J''ai arrosé les plantes et débranché le four et tous les autres appareils électriques.', 'I''ve watered the plants and unplugged the oven and all the other electrical appliances.'),
(36, 14, 'Heureusement, j''ai pensé à tout et je n''ai rien oublié. [...]', 'Fortunately (happily) I''ve thought of everything and I''ve forgotten nothing. [...]'),
(36, 15, 'Bonjour, vos passeports et billets d''avion, s''il vous plaît.', 'Good morning, your passports and plane tickets, please.'),
(36, 16, 'Oh non! J''ai laissé mon sac à main sur la table du salon!', 'Oh no! I''ve left my handbag (bag at hand) on the table in (or) the living room!'),

(37, 1, 'Ça fait deux mois que je cherche un appartement à louer.', 'I have been looking for (That makes two months that I look for) a flat to rent for two months.'),
(37, 2, 'As-tu trouvé quelque chose ?', 'Have you found something?'),
(37, 3, 'Pas encore. C''est plus compliqué que ça, et ce n''est pas fini !', 'Not yet. It''s more complicated than that, and it''s not over (finished)!'),
(37, 4, 'J''ai cherché d''abord dans l''arrondissement où j''ai grandi, mais sans succès.', 'I looked first in the neighbourhood where I grew up, but with no (without) success.'),
(37, 5, 'Ensuite, j''ai élargi mes recherches, et j''ai aussi contacté un agent immobilier.', 'Then I broadened by (my) search es) and I also contacted an estate agent.'),
(37, 6, 'J''ai n''a pas réussi à le joindre par téléphone, mais j''ai rempli le formulaire sur son site', 'I didn''t manage (succeed) to get (join) him on the (by) phone, but I filled in the form on his site'),
(37, 7, 'et j''ai fourni tous les renseignements nécessaires.', 'and I supplied (provided) all the necessary information.'),
(37, 8, 'Il m''a rappelée le lendemain et nous avons choisi plusieurs propriétés à visiter.', 'He called me back the next day and we chose several properties to visit.'),
(37, 9, 'Et alors? Tu as trouvé ton bonheur ?', 'Well? Did you find what you were looking for your happiness?'),
(37, 10, 'Il y a deux apparts dans mes moyens : l''un est plus petit que l''autre', 'There are two flats that I can afford (in my means): one is smaller than the other'),
(37, 11, 'mais il est aussi plus cher parce qu''il donne sur une cour intérieure très calme.', 'but it''s also more expensive because it gives onto a very calm interior courtyard.'),
(37, 12, 'L''autre, au premier étage, est moins intéressant : il est plus grand mais aussi plus bruyant.', 'The other, on the first floor, is less interesting: it is bigger (more big) but also noisier (more noisy).'),
(37, 13, 'Il y en a un troisième, le plus spacieux, au dernier étage. Il est plus grand que tous les autres', 'There is a third one, the roomiest (mast roomy), on the last floor. It''s bigger than all the others'),
(37, 14, 'et beaucoup plus joli, avec une énorme terrasse tout autour et rien au-dessus.', 'and much prettier (more pretty), with a huge terrace all around and nothing above.'),
(37, 15, 'Mais, malheureusement, le loyer est prohibitif. Il est plus élevé que mon salaire mensuel.', 'But, unfortunately, the rent is prohibitive. It''s higher than my monthly salary.'),
(37, 16, 'Eh oui, mon amie ! C''est difficile mais il faut vivre au-dessous de ses moyens.', 'Oh yes, my friend. It''s hard (difficult) but you have (it is necessary) to live below your (one''s) means.'),
(37, 17, 'Mais je peux t''aider, peut-être.', 'But perhaps I can help you.'),
(37, 18, 'En effet, j''ai réfléchi sérieusement à la question: est-ce que tu peux garantir mon loyer...?', 'Indeed, I''ve thought seriously about the question: can you guarantee my rent...?'),

(38, 1, 'Bonjour, j''essaie de joindre Alain Bolland. Est-il au bureau aujourd''hui ?', 'Good morning. I''m trying to reach Alain Bolland. Is he at the office today?'),
(38, 2, 'Je ne sais pas, je vais vérifier. C''est de la part de qui ?', 'I don''t know. I''ll check. Who is calling (it''s of the share of who)?'),
(38, 3, 'Dites-lui que Madame Lacroix veut lui parler.', 'Tell him that Mrs Lacroix wants to speak with him.'),
(38, 4, 'Je l''ai rencontré au Salon de l''automobile et j''ai pris sa carte de visite.', 'I met him at the Motor Show and I took his business (visit) card.'),
(38, 5, 'J''ai appris qu''il est le nouveau directeur commercial pour l''Île de France.', 'I learned that he is the new sales (commerciali manager for the Île de France (island of France).'),
(38, 6, 'Il m''a dit de l''appeler en début de semaine pour organiser une visite de vos locaux.', 'He told me to call him at the beginning of the week to organise a visit of your offices (premises).'),
(38, 7, 'Je vous mets en attente. Ne quittez pas je vous prie.', 'I''m putting you on hold (in wait). Please hold the line (do not leavel.'),
(38, 8, 'Je regrette, mais son poste ne répond pas. Il doit être à l''extérieur.', 'I''m sorry, but his extension is not answering. He must be out of the office (at the exterior).'),
(38, 9, 'Je ne suis pas surpris parce que nous avons plein de travail en ce moment et l''agenda de Monsieur Bolland est plein.', 'I''m not surprised because we have loads (full) of work at the moment and Mr Bolland''s diary is full.'),
(38, 10, 'Voulez-vous laisser un message ?', 'Do you want to leave a message?'),
(38, 11, 'Pouvez-vous lui demander de me recontacter plus tard dans la journée ?', 'Can you ask him to contact me again later in the day?'),
(38, 12, 'Entendu. Il a vos coordonnées, je présume ?', 'Of course (heard). He has your contact details, I presume?'),
(38, 13, 'Normalement oui, mais je vais vous donner un numéro où il peut me trouver à tout moment.', 'He should do (normally yes) but I''m going to give you a number where he can get (find) me at any time.'),
(38, 14, 'C''est le 07 28 91 12. Attendez, excusez-moi, c''est le 02 à la fin.', 'It''s (the) 07 28 91 12. Wait, excuse me, it''s (the) 02 at the end.'),
(38, 15, 'Si je ne réponds pas c''est parce que je suis en réunion.', 'If I don''t answer it''s because I''m in a meeting.'),
(38, 16, 'J''ai compris. Je lui laisse votre message. Au revoir et merci de votre appel.', 'I''ve understood. I''ll leave him your message. Goodbye and thank you for calling (your coll).'),
(38, 17, 'Un grand merci pour votre coopération.', 'Thank you very much (a big thankyou for your cooperation.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(36, 1, 'The expression Ça y est ("that there is") is useful for acknowledging that something is about to happen - Ça y est: la pluie arrive, Here we go: the rain is on its way- or has happened: Ça y est: le week-end est terminé, That''s it. The weekend is over. As usual, the translation will depend on the context, but the basic idea is that of recognition.', 1),
(36, 2, 'This is the perfect tense -le passé composé of verbs ending in -er Generally formed with avoir, appropriately conjugated, and the past participle of the verb, it is used to describe an action that was completed ("perfected") in the past. Although similar in structure to the present perfect tense in English (I have ordered), it is not a one-on-one equivalent. (Some verbs form their passé compose with être, as we will see later on.)', 2),
(36, 3, 'The interrogative form of the perfect tense can be constructed, like the present, in three ways: by raising the voice, inverting the auxiliary and pronoun or as here, with est-ce que: Est-ce que vous avez fermé la fenêtre ? Did you have you closed the window?', 2),
(36, 4, 'When used with the perfect tense, tout is usually placed as an adverb between the auxiliary and the participle (Il a tout fermé, He''s closed everything). Remember that the adverb tout is invariable (II a tout fermé, ils ont tout fermé).', 3),
(36, 5, 'fermer means to close (Le magasin est fermé, The shop is closed) but also to lock. To avoid ambiguity, to lock can also be expressed as fermer à clé ("close to key"). The noun a lock is une serrure. Doors and windows can also be secured with un verrou, a bolt, whence the verb verrouiller, to bolt.', 5),
(36, 6, 'We saw in lesson 30 note 8 that tout à l''heure, later on, could be used in reference to the past. In this case, it refers to an immediate or very recent event. J''ai vérifié la cuisine tout à l''heure, I checked the kitchen just now / a few minutes ago / earlier, etc. Remember that tout is used here as part of the expression, not an adverb, as in sentence 3.', 4),
(36, 7, 'The relative pronoun ce que, first seen in lesson 12, is equivalent to what/which. It functions as the direct object of a subordinate clause, often with a subject pronoun: Je mange ce que je veux, I eat what I want. Prenez ce que vous voulez, Take what you want.', 9),
(36, 8, 'nettoyer is a useful verb that means to clean or clear up, depending on the context. Like fermer, it is often followed by a noun to make the action more specific, whereas English tends to use an entirely different verb. For example, J''ai nettoyé la piscine à l''éponge, I''ve sponged down the swimming pool. We''ll see more of these equivalent constructions (verb + noun in French vs. single verb in English) as we advance The noun nettoyage à sec means dry cleaning', 12),

(37, 1, 'un arrondissement, a neighbourhood (see lesson 8) comes from the Group 2 verb arrondir, to round off and rond, round. The-ment suffix, which generally denotes an adverb, is also found in certain nouns derived from "action" verbs from all three groups. For example, juger (to Judge) -> un jugement (a judgement-notice the difference in spelling- and avertir (to warn) -> un avertissement (a warning). The difference between-ment adverbs and nouns is easy to spot because the latter are usually preceded by a definite or indefinite article.', 4),
(37, 2, 'The perfect tense of Group 2 verbs (regular, ending in -ir) is usually constructed with avoir and the past participle, formed by dropping the final-r from the infinitive. For example, grandir (to grow up) -> grandi: j''ai grandi, tu as grandi, il/elle a grandi, nous avons grandi, vous avez grandi, ils/elles ont grandi. Simple!', 4),
(37, 3, 'Continuing the series of nouns that can be plural in French but not in English, la recherche has two meanings, research, in which case the noun is usually singular and has a definite article-La recherche scientifique est très importante, Scientific research is very important-and, more generally, a search or an investigation, in which case, it takes an indefinite article but can also be plural: Nous allons continuer nos recherches, We are going to keep searching. For web browsing (see lesson 27), we use un moteur de recherche, a search engine', 5),
(37, 4, 'le bonheur means happiness or good fortune. Après, trois mariages, elle a enfin trouvé le bonheur être seule, After three marriages, she finally found happiness: being alone. The word can also be used in idiomatic expressions such as Est-ce que tu as trouvé ton bonheur?, Have you found what you wanted or were looking for? The opposite of le bonheur is le malheur, unhappiness, misfortune. Remember this proverb. Un malheur n''arrive jamais seul, Misfortunes never come on their own, or, more colloquially, It never rains but it pours. (The h is silent in both words.).', 9),
(37, 5, 'un appartement, a flat or an apartment (notice the difference in spelling), is one of the multisyllabic words that are frequently abbreviated in spoken French (lesson 17 note 7). It becomes un appart, with the final t pronounced', 10),
(37, 6, 'le moyen, in the singular, is the way or the means: Je connais un bon moyen d''apprendre une langue, I know a good way to learn a language. In the plural, it is equivalent to the singular English noun means, ie, money. Nous n''avons pas les moyens d''aller en vacances cette année, We don''t have the money to go on holiday this year. In this case, avoir les moyens is a good paraphrase for to afford, which has no direct equivalent in French.', 10),
(37, 7, 'By now, you should be familiar with the comparatives of superiority and inferiority, where more is translated by plus and less by moins In both cases the conjunction than is que. Lyon est plus grand que Toulouse mais plus petit que Paris, Lyon is bigger than Toulouse but smaller than Paris. To form the superlative, simply put the definite article le or la for the singular (depending on the gender of the noun) and les for the plural before plus or moins.', 10),
(37, 8, 'dessus and dessous mean above and below / beneath, respectively. They are used in different forms, but here we see them, with au-, as adverbs. J''habite au troisième étage et ma copine habite à l''étage au-dessus, I live on the third floor and my girlfriend lives on the floor above La température est deux degrés au-dessous de zéro, The temperature is two degrees below zero. (You will have recognised the adjective sous, under) In some cases, au-dessous is replaced with en dessous, but the meaning is exactly the same.', 14),

(38, 1, 'une part is a piece or a slice: Voulez-vous une part de gâteau au chocolat? Do you want a piece of chocolate cake? In a telephone conversation, however, the expression de la part de identifies the person on behalf of whom the call is being placed. The standard question is: C''est de la part de qui ?, equivalent in register to Who shall I say is calling? Giving one''s name is a sufficient response. The caller can also say, for example, Je l''appelle de la part de Michelle, in which case, the caller may be Michelle herself or someone calling on her behalf.', 2),
(38, 2, 'Here is the perfect tense of certain Group 3 verbs ending in -re, such as prendre, to take, and its derivatives: j''ai pris, tu as pris, il/elle a pris, nous avons pris, vous avez pris, ils/elles ont pris.', 4),
(38, 3, 'Another set of-re verbs, including dire, to say, lire, to read, and écrire, to write, form their past participle with a final (and silent) t: j''ai dit. tu as dit, il elle a dit, nous avons dit, vous avez dit, ils/elles ont dit Naturally, any verbs derived from these three, such as contredire, to contradict, are conjugated in the same way.', 6),
(38, 4, 'The adjective local has the same meaning as in English (un guide local, a local guide). As a noun, however, it means premises, In contrast to English, it can be either singular or plural: un local commercial, des locaux commerciaux, commercial premises. The difference is merely a question of size, with the plural being used for a larger facility. (Remember that nouns and adjectives ending in -al form the plural with aux.)', 6),
(38, 5, 'We are familiar with je vous en prie (see lessons 31 and 35). In very formal contexts, however, the en can be dropped, particularly if the expression appears at the end of a sentence. Entrez, je vous prie, Please come in. You are unlikely to use je vous prie (and the tu form is very rarely used); however, you will probably hear it in certain circumstances, notably on the phone.', 7),
(38, 6, 'A few nouns have two genders, each with a different meaning. One of the most common is poste. Une poste is a post office (lessons 29 and 35) but un poste means a position or job. II quitte le poste de directeur en mai, He is leaving the position of director in Mary. The masculine word also means a switchboard extension in a telephone system. Le poste ne répond pas, The extension is not answering. You can see why we insist on memorising not only the meaning of nouns but also their gender!', 8),
(38, 7, 'The adjective plein (feminine pleine, pronounced [plen]) means full or busy (think: plenty): Les hôtels sont toujours pleins en été, The hotels are always full in summer. The invariable expression plein de means full of and, more broadly, lots of Elle a plein de choses à faire, She has lots to do.', 9),
(38, 8, 'entendu is the past participle of entendre, to hear: J''ai entendu un bruit, I heard a noise. But the word can be used alone in response to a statement that you acknowledge or agree with. Venez tôt demain. Entendu. Come early tomorrow. - Will do. Of course, the actual translation will depend on the context but, in every case, avoid the (bad) French habit of saying OK instead of Entendu!', 12),
(38, 9, 'les coordonnées, coordinates, is the geographical term for distances or numbers identifying a position. By extension, it is commonly used to refer to a person''s contact details in the general sense. Thus Donnez-moi vos coordonnées can be translated as Give me your address / your contact details / your name and number, etc. If further details are needed, an adjective can be added for instance, Donnez-moi vos coordonnées téléphoniques or bancaires if you want the person''s phone number or bank details.', 12);

INSERT INTO contents (course_id, seq, french, english) VALUES
(39, 1, 'La France possède une longue tradition cinématographique, et le "septième art" est bien vivant aujourd''hui.', 'France has (possesses) a long cinematographic tradition, and the "seventh art" is truly alive today.'),
(39, 2, 'Malgré toutes les plateformes de diffusion et tous les autres supports disponibles,', 'Despite all the streaming (broadcasting) platforms and all the other media (supports) available,'),
(39, 3, 'beaucoup de gens vont deux ou trois fois par semaine au cinéma.', 'many people go twice or three times a week to the cinemas.'),
(39, 4, 'Et les metteurs en scène et comédiens français sont très appréciés par le public.', 'And French directors (putters-on-stage) and actors are much appreciated by audiences (the public).'),
(39, 5, 'Le choix de films est énorme - comédies, aventures, policiers, dessins animés, et cætera.', 'The choice of movies is huge: comedies, adventures, detective films, cartoons (animated drawings), etc.'),
(39, 6, 'Naturellement, il y a aussi beaucoup de films étrangers dans les "salles obscures",', 'Naturally, there are also a lot of foreign films in the "dark (obscure) rooms,"'),
(39, 7, 'qu''on peut voir en version originale ou en version française (c''est-à-dire doublés).', 'which one can see in [the] original [language] version or in the French version (that is to say, dubbed).'),
(39, 8, 'Deux rendez-vous annuels sont indispensables pour les cinéphiles :', 'Two annual get-togethers are indispensable for movie movers:'),
(39, 9, 'le festival de Cannes avec sa Palme d''Or, et la soirée des Césars;', 'the Cannes festival with its Golden Palm, and the Césars evening;'),
(39, 10, 'ces prix récompensent le meilleur du cinéma de l''année, notamment le meilleur film et le meilleur scénario.', 'these prizes reward the best of the year''s cinema, notably best film and best screenplay.'),
(39, 11, 'La semaine dernière, des millions d''amateurs en ont suivi la cérémonie de clôture.', 'Last week millions of fans followed the closing ceremony.'),
(39, 12, 'Ils ont vu la maîtresse et le maître de cérémonie présenter les prix aux gagnants.', 'They saw the hostess and the host (the mistress and the master of ceremony) present the awards to the winners.'),
(39, 13, 'Et maintenant, le moment que nous attendons tous: le César du meilleur metteur en scène.', 'And now the moment that we''ve all been waiting for: the César for the best director.'),
(39, 14, 'Cette année il est attribué à... Michel Bonnaud pour "Commencez sans moi".', 'This year it is awarded to... Michel Bonnaud for his movie Start Without Me.'),
(39, 15, 'Essayant de rester décontracté, le gagnant répond:', 'Trying to remain relaxed, the winner answered:'),
(39, 16, 'Merci, je n''ai jamais reçu un prix de la mise en scène .', 'Thank you. I''ve never had (receive) a director''s award.'),
(39, 17, 'Mais je suis étonné car je n''ai pas tourné un seul film depuis vingt ans.', 'But I''m astonished because I haven''t made (turned) a single film for twenty years.'),
(39, 18, 'C''est justement pour ça que le jury vous donne cette récompense, mon cher Michel!', 'That''s exactly (justly) why the jury is giving you this reward, my dear Michel!'),

(40, 1, 'Tu veux venir avec moi au ciné ce soir ? Il y a plein de nouveautés à voir cette semaine.', 'Do you want to come with me to the flicks this evening? There are loads of new things to see this week.'),
(40, 2, 'Où est-ce que j''ai mis le guide des spectacles ? Je l''ai perdu? Non, le voici.', 'Where did I put the entertainment guide? Did I lose it? No, here it is.'),
(40, 3, 'Regarde: "L''Etranger du nord", c''est le dernier film avec l''acteur russe que tu aimes bien.', 'Look: "The Stranger from the North," it''s the latest film with the Russian actor you like a lot.'),
(40, 4, 'Bof, j''ai vu la bande-annonce. Je déteste les films d''action et, en réalité, je n''aime pas trop cet acteur.', 'You reckon? I''ve seen the trailer (tope-announcement). I hate action movies and, in reality, I''m not too keen on that actor.'),
(40, 5, 'Fais un effort! Bois ton café et aide-moi à choisir quelque chose.', 'Make an effort! Drink your coffee and help me to choose something.'),
(40, 6, 'Je l''ai bu. En fait, j''en ai déjà pris trois ce matin. As-tu une autre proposition de film ?', 'I''ve drunk it. In fact, I''ve already had (taken) three this morning. Have you [got] another film to suggest (proposal)?'),
(40, 7, '"Le Vieux port". L''action a lieu dans le sud de la France. J''ai entendu de bonnes critiques.', '"The Old Port." The action takes place in the south of France. I''ve heard good reviews.'),
(40, 8, 'Ah non, il est nul ce film ! Autre chose ?', 'Oh no, it''s a dreadful film! Anything else?'),
(40, 9, 'Une comédie musicale ? Non, ce n''est pas vraiment ton truc .', 'A musical (comedy)? No, it''s not really your thing.'),
(40, 10, 'Si, si. J''en ai vu une - "Entre l''est et l''ouest" -, et elle m''a plu.', 'Oh yes it is. I saw one -"Between East and West"- and I liked it (it me-pleased).'),
(40, 11, 'À quelle heure sont les séances au multiplexe du centre commercial? [...]', 'What time are the showings at the multiplex in the shopping centre? [...]'),
(40, 12, 'Dans quelle salle passe le film? Il y en a une douzaine.', '(In) Which screen is showing (passes) the movie? There are around twelve of them.'),
(40, 13, 'Il faut d''abord faire la queue ici pour avoir le tarif étudiant.', 'You first have (it is necessary firstly) to (make the) queue here to get the student rate.'),
(40, 14, 'Comment, tu n''as pas pris les billets à la billetterie en ligne ?', 'What (How), you didn''t get the tickets from the online box office?'),
(40, 15, 'Non, je suis bête. Je n''y ai pas pensé.', 'No, I''m silly. I didn''t think of it.'),
(40, 16, 'J''ai horreur d''attendre. Allons prendre un verre quelque part.', 'I hate (hove horror) waiting. Let''s go a have a drink somewhere.'),

(41, 1, 'Allô, bonjour. Je suis bien au restaurant "La Fleur d''Argent"?', 'Hello, good morning. Have I reached (lam well at) the restaurant "The Silver Flower"?'),
(41, 2, 'Oui monsieur. Vous y êtes.', 'Yes sir, you are (there).'),
(41, 3, 'J''essaie de vous joindre depuis deux jours. Ça sonne toujours occupé.', 'I''ve been trying to reach you for two days. The line is (it rings) always busy.'),
(41, 4, 'J''en suis conscient. Mais depuis que nous sommes dans le guide touristique,', 'I am aware of that. But since we have been in the tourist (touristic) guidebook'),
(41, 5, 'le téléphone n''arrête pas de sonner et nous sommes complets presque tous les soirs.', 'the phone hasn''t stopped ringing and we are full almost every night.'),
(41, 6, 'Vous pouvez toujours essayer de réserver avec l''application MaTable.fr. C''est plus sûr.', 'You can always try to reserve with the MaTable.fr application. It''s safer.'),
(41, 7, 'Oui, je connais cette appli, mais je préfère avoir une voix humaine au bout du fil .', 'Yes, I know that app but I prefer to have a human voice at the [other] end of the line (wire).'),
(41, 8, 'Comme vous voulez. Combien êtes-vous et à quelle heure souhaitez-vous dîner ?', 'As you wish. How many are you and (at) what time do you wish to have dinner?'),
(41, 9, 'Vers vingt heures trente, pour quatre couverts. À la terrasse si possible.', 'Around 8.30, for four people (covers). On the terrace if possible.'),
(41, 10, 'Huit heures et demie, dites-vous? Oui, il me reste une petite table pour quatre.', '8.30 you say? Yes, I still have (there me remains) a small table for four.'),
(41, 11, 'Mais à l''intérieur, car toutes les tables dehors sont prises. Cela vous convient-il ?', 'But inside, because all the tables outside are taken. Does that suit you?'),
(41, 12, 'Si vous n''avez rien d''autre.', 'If you have nothing else.'),
(41, 13, 'Alors je note. C''est à quel nom ?', 'Alright, I''ll note [that down . What''s the name?'),
(41, 14, 'Ferré, comme le chanteur. Mais rassurez-vous: je ne chanterai pas.', 'Ferré, like the singer. But rest assured (reassure you): I won''t sing.'),
(41, 15, 'Très drôle... J''ai besoin d''un numéro de portable', 'Very funny ... I need a mobile number'),
(41, 16, 'ainsi que les détails de votre carte bancaire, pour éviter une annulation de dernière minute.', 'as well as the details of your bank card, to avoid a last-minute cancellation.'),
(41, 17, 'Vous voulez aussi mon chéquier, ou mes empreintes digitales peut-être ?', 'Maybe you also want my cheque book or fingerprints (digital imprints)?'),
(41, 18, 'C''est bien ça. Vous pouvez me les envoyer par texto.', 'That''s right. You can text them to me (send them to me by text).');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(39, 1, 'Most of this text is in a formal register, as used in the press, for example, in these contexts, French often shuns "ordinary" verbs such as être and avoir, replacing them with fancier synonyms. Here, for example, La France a une longue tradition is rephrased using the regular verb posséder, to possess. Likewise, the cinema is known as le septième art, the seventh art. This tendency to "upgrade" simple concepts can be disconcerting at first, but it soon becomes a familiar trope.', 1),
(39, 2, 'la diffusion comes from the verb diffuser, to diffuse but, more commonly, to spread or broadcast. The noun is used in terms such as la diffusion vidéo, streaming, and la baladodiffusion, podcasting. These are relatively new coinages that have certainly not replaced the imported terms le streaming and le podcasting in everyday speech.', 2),
(39, 3, 'Here is a good example of how nouns are derived from verbs. From the verb mettre, to put, we get un metteur en scène ("a putter in stage"), a film director or a stage director, and la mise en scène, direction', 4),
(39, 4, 'Another literary device used in formal writing is metonymy, the use of a related term to stand in for an object or concept: les salles obscures ("the dark rooms") is used always in the plural to mean cinemas However, the regular adjectives for dark are sombre (the absence of light, pronounced (soh"bruh]) or foncé (any colour approaching black): Mon nouveau pull est bleu foncé, My new sweater is dark blue.', 6),
(39, 5, 'We know that un rendez-vous means a meeting or an appointment (lesson 4, for example). But it can also be used figuratively when referring to an event attracting large numbers of people, Le Salon de l''automobile est le rendez-vous annuel des tous ceux qui aiment les voitures, The Motor Show is the annual get-together for everyone who loves cars. Because the final letters on both components of this compound noun are -s and -z, respectively, it does not change in the plural (des rendez-vous).', 8),
(39, 6, 'The Latin and Greek origins of French are evident in many everyday words. Here, for example, we have the suffix -phile (from the Greek philos, friend), With its Anglo-Saxon roots, English would translate this as lover for example un bibliophile, a book-lover, un cinéphile, a film-lover or movie buff. The opposite suffix is -phobe (from phobos, fear): un aquaphobe someone who is scared of water. These types of words are not considered formal.', 8),
(39, 7, 'suivi is the past participle of the Group 3 verb suivre, to follow. Two other common verbs from the same group with the -i participle ending are finir fini (to finishifinished) and dormir dormi (to sleep/slept).', 11),
(39, 8, 'Here''s another the past participle of a Group 3 verb: voir vu, to see -> seen. Note also venir venu, to come came and avoir eu, to have had.', 12),
(39, 9, 'Introduced in lesson 23 note 9, the present participle of all three verb groups ends in -ant essayer essayant (try trying), finir finissant (finish finishing), rendre rendant (give back giving back). Note how the participle is used as an adjective les arts vivants, the performing ("living") arts.', 15),

(40, 1, 'In this lesson we come across two sets of Group 3 verbs with their past participles: mettre mis and prendre pris along with perdre -> perdu, boire -> bu, entendre entendu, and plaire plu. More details in lesson 42.', 2),
(40, 2, 'We saw the adjective étranger, foreign, in lesson 39. The noun is identical: un étranger / une étrangère. It has two meanings: a foreigner and a stranger (the latter derived directly from French). The context should make the meaning clear-for example, la Légion étrangère, the Foreign Legion. Don''t confuse the adjectives étranger and étrange, strange Quelle question étrange! What a strange question!', 3),
(40, 3, 'dernier/dernière means both last (lesson 14) and latest. Once again, context is key, because le dernier film de l''acteur can mean the actor''s last film (if he made no more movies or is deceased) and the actor''s latest film (their most recent performance). If in doubt, ask a movie buff or google the name!', 3),
(40, 4, 'The familiar register in this lesson is in sharp contrast to the formality of the previous one. For example: the one-word exclamation Bof is a concise idiomatic way of expressing indifference. It can be translated in several ways: Qu''est-ce que tu penses de ce film? Bof. What do you think of this movie? Not much/Meh/Whatever, etc.', 4),
(40, 5, 'Another familiar usage is nul (line 8). After a noun, the word literally means nil or null and void. But in idiomatic language, it indicates that the thing or person being described is useless, worthless, terrible, etc Cet acteur est nul, That actor is terrible. Being an adjective, nul agrees with its noun Cette actrice est nulle.', 8),
(40, 6, 'un truc, a thing (lesson 30 note 1), is used in the same way as in English to express something one likes or is keen on Ce n''est pas mon/son/leur truc, It''s not my/his/her/their thing. Le sport, c''est son truc, He/she is into sports.', 9),
(40, 7, 'We know that si means both if and so (lesson 32 note 1). It can also be used like oui when contradicting a negative statement, thus performing the same function as the repetition of the auxiliary in English: II n''aime pas le chocolat. Si. He doesn''t like chocolate Yes he does. To add extra insistence, the word is repeated. Si si, il l''adore, Oh yes he does, he loves it.', 10),
(40, 8, 'The suffix-erie, seen in lesson 25, can designate any place serving a specific function: un billet une billetterie, a ticket/ticket office, une huile une huilerie, oil (vegetable, etc.) / an ail mill or factory. Look for root word and work from there', 14),
(40, 9, 'une bête (the origin of beast) means an animal or a creature. As an adjective, it is used colloquially to mean silly or idiotic Ton idée est bête, Your idea is silly. A useful expression, in response to an acceptable suggestion, is Ce n''est pas bête. Nous allons vendre notre voiture, - Ce n''est pas bête. We are going to sell our car. That''s not a bad idea.', 15),
(40, 10, 'un verre, a glass (lesson 24 line 12) is used socially in the expression prendre un verre, to have / get a drink: Tu veux voir un film ou aller prendre un verre? Do you want to see a movie or go for a drink?', 16),

(41, 1, 'accueillir has many different translations. Basically, it means to welcome, but it can be used in the broader sense of to meet, to pick up, etc Mon amie Nadège m''a accueilli à l''aéroport, My friend Nadège met me at the airport. The noun un accueil means a welcome, a reception, but the translation will depend on the context. Merci de votre accueil can mean Thanks for making me welcome or Thanks for having me. In a public building, look for the sign Accueil, the reception desk.', 1),
(41, 2, 'The preposition depuis (lesson 39 line 17) translates both for and since It is used with the present tense, not the past: Je connais cet homme depuis vingt ans, I have known that man for twenty years. Elle est malade depuis Noël, She has been sick since Christmas.', 3),
(41, 3, 'Here is another common example of apocope (lesson 17 note 7), which mirrors English usage. The noun for a software routine, une application (line 6), is generally shortened to une appli, an app. This process of truncating long words is usual in technical contexts such as computing', 7),
(41, 4, 'un fil, a wire, is often used in reference to telephones, even though landlines have almost vanished. Two common expressions are passer un coup de fil, to make phone call, give someone a ring, and au bout du fil, on the line. Do not confuse the plural les fils with the word for sont un fils/des fils. In the latter case, the singular and the plural are both pronounced (feess), compared with [feel] for fil/fils.', 7),
(41, 5, 'souhaiter is a formal verb meaning to wish (for) or to hope that. It is common in polite contexts. À quelle heure souhaitez-vous venir? What time do you wish/want to come? The noun, un souhait ((soo-ay ) means a desire, a wish. The verbal response to someone sneezing is À tes/vos souhaits! ("to your desires"), an exclamation inducted into English as Atishool', 8),
(41, 6, 'un couvert, from the verb couvrir, to cover, means a place-setting in culinary contexts, hence the expression mettre le couvert, to lay the table in a restaurant context, the noun refers to a customer or diner (known in the trade as "a cover"). Don''t confuse un couvert with un couvercle, meaning a lid or top of a container', 9),
(41, 7, 'Remember that past participles used as adjectives must agree with their noun, so Gabriel est pris ce soir / Gabriel et Marc sont pris ce soir/Lucie est prise ce soir/Toutes les tables sont prises ce soir.', 11),
(41, 8, 'See lesson 26 note 2. Using an inverted pronoun, rather than est-ce que, to ask a question is formal but quite common in formal social interaction. So instead of Est-ce que cela vous convient ? the restaurant owner enquires Cela vous convient-il ? (Listen to the liaison between the final t and the initial vowel,)', 11),
(41, 9, 'This is our first encounter with the future tense, which, in contrast to English, is formed not with an auxiliary but by changing the verb ending: chanter, to sing, je chanterai.', 14),
(41, 10, 'Despite the prevalence of English, French has succeeded in coining "native" terms in the field of technology One example is un texto, an SMS. Even so, many young people in France (though not in Canada) opt for the English term un SMS. Which is unnecessary because the verb texter means to text!', 18);

INSERT INTO contents (course_id, seq, french, english) VALUES
(43, 1, 'J''ai trouvé cet article, sur le-foot.fr, qui peut t''intéresser.', 'I found this article on le-foot.fr, which may interest you.'),
(43, 2, '"Manuel Alonso est nommé entraîneur de l''équipe nationale de football féminine,', '"Manuel Alonso has been named [as] trainer of the women''s national football team,'),
(43, 3, 'succédant à Madame Manon Bardouin, qui est partie à la retraite après une carrière bien remplie.', 'taking over from Mrs Manon Bardouin, who has retired (left to the retirement) after a fulfilled (well filled) career.'),
(43, 4, 'Il est né en Espagne en mille neuf cent quatre-vingt-dix-neuf. Ses parents sont morts dans un accident de la route.', 'He was (is) born in Spain in 1999. His parents died (are dead) in a road accident.'),
(43, 5, 'Peu de temps après, Manuel est venu vivre avec son oncle et sa tante dans le sud de la France.', 'Shortly (little time) after, Manuel came (is come) to live with his uncle and his aunt in the south of France.'),
(43, 6, 'Il est allé au lycée à Nice et, ensuite, est monté à Paris pour faire des études à l''université.', 'He went (is gone) to high school in Nice and then went up (is mounted) to Paris to study at university.'),
(43, 7, 'Il est entré à la faculté de droit, où il est devenu un fan de sports d''équipe.', 'He went (is entered) to law school (faculty of law), where he became (is become) a fan of team sports.'),
(43, 8, 'Un soir, il est allé voir un match international féminin entre les Pays-Bas et l''Allemagne.', 'One evening, he went to a women''s international match between the Netherlands and Germany.'),
(43, 9, 'Le jeu lui a vraiment plu et il a pris la décision de travailler comme entraîneur dans ce sport en Europe."', 'He really liked the game (the game to-him was really pleasing) and he decided (took the decision) to work as [a] coach (trainer) in that sport in Europe."'),
(43, 10, 'Est-ce qu''il est rentré en Espagne ?', 'Did he go back (is re-entered) to Spain?'),
(43, 11, 'Non, il est retourné à la fac pour étudier la gestion sportive.', 'No, he returned (is returned) to the university to study sports (sporty) management.'),
(43, 12, '"Manuel est sorti trois ans plus tard, avec son diplôme en poche et plusieurs offres d''emploi.', '"Manuel came out (is exited) three years later, with a diploma in [his] pocket and several job offers.'),
(43, 13, 'Il est allé travailler avec l''équipe de Rennes, où il est resté longtemps.', 'He went to work with the Rennes team, where he stayed (is remained) [a] long time.'),
(43, 14, 'Après cette expérience, il est passé d''un club à un autre pendant quelque temps', 'After that experience, he went (is passed) from one club to another for some time'),
(43, 15, 'avant d''être nommé au poste d''entraîneur officiel de l''équipe féminine de Bordeaux.', 'before being appointed to the post of official trainer of the Bordeaux women''s team.'),
(43, 16, 'Il est arrivé au bon moment. L''équipe est montée très vite en haut du classement,', 'He arrived at the right (good) time. The team quickly rose (is mounted) to the top of the ranking.'),
(43, 17, 'et le directeur lui a demandé de rester."', 'and the director asked him to stay."'),
(43, 18, 'Mais alors, pour quelle raison ? Pourquoi choisir un entraîneur et pas une entraîneuse ?', 'But then, for what reason? Why choose a [male] trainer and not a [female] trainer?'),
(43, 19, 'Bonne question! Je ne peux pas l''expliquer facilement.', 'Good question! I can''t (it) explain easily.'),
(43, 20, 'Personne ne le sait vraiment.', 'No one really knows (no-one not it knows).'),

(44, 1, 'Si vous n''avez pas un titre de transport électronique, madame,', 'If you don''t have an e-ticket (electronic transport certificate), madam,'),
(44, 2, 'vous pouvez acheter votre billet dans le distributeur automatique au bout du quai.', 'you can buy your ticket in the automatic machine (dispenser) at the end of the platform.'),
(44, 3, 'Merci, mais il m''en faut deux: un aller simple pour moi et un aller-retour pour mon cousin.', 'Thanks, but I need two: a single (a to-go simple) for me and a return (a to-go-return) for my cousin.'),
(44, 4, 'Dans ce cas, la billetterie est là-bas, vers les consignes et les Objets trouvés.', 'In that case, the ticket office is over there, towards the left-luggage [lockers] and the lost property office (found objects).'),
(44, 5, 'Vous voyez les deux files d''attente devant les guichets ?', 'You see those two queues (lines of-wait) in front of the ticket offices?'),
(44, 6, 'Prenez celle de gauche: elle avance plus vite que l''autre... enfin, moins lentement. [...]', 'Take the one on the left: it''s moving faster than the other one...well, less slowly. [...]'),
(44, 7, 'C''est bon, Jules, j''ai les billets. Je vais les composter.', 'It''s okay, Jules, I have [got] the tickets. I''m going to time-stamp them.'),
(44, 8, 'Fais attention à ne pas les mettre dans le mauvais sens dans la machine!', 'Be careful (do attention) not to put them the wrong way around (bad direction) in the machine!'),
(44, 9, 'C''est énervant! On affiche partout "Le compostage est obligatoire",', 'That''s annoying! There are signs (one posters) everywhere saying [saying]: "Time-stamping is obligatory,"'),
(44, 10, 'mais toutes les machines sont hors service et je n''ai pas pu valider les billets.', 'but all the machines are out of order (service) and I couldn''t validate the tickets.'),
(44, 11, 'À ce moment-là, il faut le signaler au contrôleur à bord du train.', 'In that case, you have to report (signal) it to the inspector on board the train.'),
(44, 12, 'Veux-tu de l''aide pour porter ton sac ? Il a l''air très lourd.', 'Do you want help carrying your bag? It looks very heavy.'),
(44, 13, 'Non merci, il est grand mais en réalité il est assez léger.', 'No thanks, it''s big but it''s actually (in reality) quite light.'),
(44, 14, 'Attends une minute, je regarde le tableau d''affichage des trains de grandes lignes :', 'Wait a minute, I''m looking at the display board for the mainline trains (trains of big lines):'),
(44, 15, '"Circulation perturbée: Nancy: Train en panne; Colmar: Retard; Mulhouse: Annulé".', '"Traffic disrupted: Nancy: Train broken down; Colmar: Late; Mulhouse: Cancelled."'),
(44, 16, 'Il n''y a même pas de trains omnibus ! C''est toujours la même chose et j''en ai marre !', 'There aren''t even any stopping trains! It''s always the same thing and I''m fed up!'),
(44, 17, 'À chaque fois il y a des soucis avec ces lignes, vrai ou faux?', 'Every time there are issues with these lines, true or false?'),
(44, 18, 'Je suis d''accord, mais il vaut mieux prendre notre mal en patience.', 'I agree (am of-accord). It''s true but it''s better to grin and bear it (take our pain in patience).'),
(44, 19, 'Il n''en est pas question. Je vais plutôt prendre le car!', 'Out of the (it not of it is not) question. I''m going to take a (the) coach instead!'),

(45, 1, 'On m''a invitée aujourd''hui pour vous parler des réseaux sociaux professionnels.', 'I have been invited (one me has invited) to talk to you about professional social networks.'),
(45, 2, 'Bien entendu, le monde du travail a changé considérablement depuis vingt ans.', 'Of course (well heard), the world of work has changed considerably in (since) twenty years.'),
(45, 3, 'Mon père, que j''admire, a travaillé toute sa vie dans la même usine,', 'My father, whom I admire, worked all his life in the same factory,'),
(45, 4, 'alors que mon frère, qui a vingt-cinq ans, a déjà changé plusieurs fois d''entreprise.', 'whereas (then that) my brother, who is twenty-five, has already changed companies several times.'),
(45, 5, 'De nos jours, on peut devenir avocat, ingénieur, journaliste, comptable ou programmeur,', 'Nowadays (of our days), you can become [a] lawyer, [an] engineer, [a] journalist, [an] accountant or [a] programmer,'),
(45, 6, 'mais aussi boucher, coiffeur, cuisinier ou plombier: il n''y a pas de métiers inutiles.', 'but also [a] butcher, [a] hairdresser, [a] cook or [a] plumber: there are no useless jobs.'),
(45, 7, 'Je veux vous parler de ce que je sais faire, plutôt que de ce que je voudrais faire.', 'I want to talk to you about what I know how to do, not (rather than) what I would like to do.'),
(45, 8, 'Je suis conceptrice multimédia et consultante,', 'I am [a] multimedia designer and consultant,'),
(45, 9, 'un métier qui demande une excellente formation, et pas mal de connaissances techniques.', 'a job that requires excellent training, and quite a lot of technical knowledge.'),
(45, 10, 'Ce que j''apprécie le plus dans mon travail c''est qu''il m''offre la possibilité de rencontrer des gens aussi passionnés que moi.', 'What I appreciate the most about my work is that it gives (offers) me the possibility to meet people who are as passionate as I am (me).'),
(45, 11, 'Ce qui est difficile est qu''on est toujours en train de voyager: en avion, en train, parfois en bateau;', 'What is difficult is that we''re always in the process of travelling: by (in) plane, train and sometimes boat;'),
(45, 12, 'on n''arrête pas de bouger! Nous ne pouvons pas prendre de congés,', 'we never stop moving! We can''t take any holidays,'),
(45, 13, 'et nous ne passons jamais assez de temps dans les villes que nous visitons, ce qui est dommage.', 'and we never spend enough time in the cities that we visit, which is a pity.'),
(45, 14, 'Mais, bon, c''est comme ça. Et les choses changent tellement vite !', 'But, well, that''s the way it is (it''s like that). And things change so quickly!'),
(45, 15, 'Que faites-vous maintenant, madame ? Toujours le même métier ?', 'What do you do now, madam? Still the same job?'),
(45, 16, 'Non, je suis entre deux emplois. Ce qui veut dire que je suis au chômage.', 'No, I''m between two jobs. Which means (wants to say) that I''m unemployed.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(43, 1, 'The names of many sports have been imported into French as masculine nouns. They include **le tennis**, **le golf**, **le squash** and **le volley-ball**. In a couple of cases, the names have been shortened. This is notably the case of **le football** (**le foot**) and **le basket-ball** (**le basket** - the final t is pronounced). However, not all French sports have English names (for example, **la natation**, *swimming*) so always check in a dictionary.', 1),
(43, 2, 'When making the agreement between a compound noun and an adjective, always look for the root word, in this case **équipe**, which is feminine (**une équipe féminine**, see line 15). With the noun **l''équipe de football**, the adjective will agree with the head word, **l''équipe**, not the second noun, **football**. By contrast, with a single noun, the agreement is simple: **le football féminin**.', 2),
(43, 3, 'Certain verbs are conjugated in the perfect tense with **être** instead of **avoir** when used intransitively. This lesson contains the main ones you will need to know, such as **partir**, *to leave*: **je suis parti, tu es parti, il est parti, nous sommes partis, vous êtes partis, ils sont partis**. Another major difference with **avoir**-conjugated verbs is that the past participle agrees with the subject (see lesson 42), thus **Monsieur Grégoire est parti** / **Madame Grégoire est partie**.', 6),
(43, 4, '**naître** is a very irregular verb, meaning *to be born*. It is conjugated with **être** in the prefect tense, so **il est né / elle est née** means *he / she was born* (not is). (The noun from **naître** is **la naissance**, *birth*, see lesson 23). The same conjugation rule applies to **mourir**, *to die*: **je suis mort / morte, tu es mort/-e, il/elle est mort/-e**, *I / you / he died*, etc.', 4),
(43, 5, '**plaire** (past participle: **plu**) means *to please* (see lesson 32 line 13) but is used with the preposition **à** and an indirect object as a synonym for *to like*. In this case, the word is the reverse of English. **La nouvelle maison plaît à la famille**, *The family likes the new house* (literally: "The new house is pleasing to the family"). If a pronoun replaces the noun, it comes before the verb: **Le film lui a plu**, *He liked the film*. The same rule applies, for example, to **demander à**: **Je vais demander à l''entraîneur -> Je vais lui demander**, *I''m going to ask the coach/him or her*. When learning a new verb, make sure to check the preposition, if any, that goes with it.', 9),
(43, 6, 'Masculine adjectives ending in **-if** form the feminine with **-ive**: **sportif -> sportive** (*sporty*), **créatif -> créative** (*creative*), **agressif -> agressive** (*aggressive*). Note how the feminine form is often used in English as an adjective.', 11),
(43, 7, '**quelque temps** is an indefinite (and thus invariable) adjective describing a short time period: *a while*, or the literal translation *some time*. **Je ne les ai pas vus depuis quelque temps**, *I haven''t seen them for a while*. Contrast this with **longtemps** (line 13), *a long time*, written as a single word. (Don''t confuse **quelque temps** with the single word **quelquefois**, *sometimes*.)', 14),
(43, 8, 'Adding the definite article to **bon**, *good*, changes the meaning slightly, to *correct, proper*, or *right*. **Tu es arrivé au bon moment**, *You came at the right time*. **Ce n''est pas la bonne question**, *That''s not the right question*. One of the all-time classic guides to French grammar (written by a Belgian) is Le Bon Usage, which translates as *proper usage*.', 16),
(43, 9, 'Here, **personne** is not a noun (lesson 19 line 3) but an indefinite pronoun, meaning *no one, nobody, anyone*. It can be either the subject or the object of a verb, and the accompanying verb is always in negative. **Personne ne le sait**, *No one knows*. **Je ne connais personne ici**, *I don''t know anyone here*.', 20),

(44, 1, 'We know that **un titre** means *a title* (book, movie, job, etc., lesson 17 line 11). By extension it also means *a deed* or *a right*, as found in expressions like **un titre de transport**, *a ticket travel card or other "document of carriage"*. As usual, context is all-important: when buying a train ticket, you would ask for **un billet** but an inspector would likely ask you to show your **titre de transport**. (Remember that **un ticket** is used for tickets on **le métro**)', 1),
(44, 2, '**un quai** is the origin of the English cognate *quay* (it also means *wharf*). More broadly, it designates an embankment or riverside road. In a train station, **un quai** is a *platform*, although the synonym **une voie** ("a way") is also used, particularly in passenger announcements. **Le train partira de la voie numéro trois**, *The train will depart from platform number three*.', 2),
(44, 3, 'In a travel context, **un billet aller simple** (or just **un aller simple**) means a *one-way or single ticket*. A return (or round-trip) ticket is **un (billet) aller-retour**. The term for a season ticket is **une carte d''abonnement**, literally "a subscription card," or simply **un abonnement** (from the verb **s''abonner**, *to take out a subscription*).', 3),
(44, 4, 'In some cases, **mauvais** (fem, **mauvaise**), *bad*, can mean *wrong*: **Vous avez fait un mauvais numéro**, *You''ve got the wrong number*. It is usually used as an attributive adjective and comes before the noun, without a connecting verb. However, there are several other ways of saying *wrong*, including **faux** (line 17), as we shall see later on.', 8),
(44, 5, '**un sens** generally means a *sense*, in terms of either rationality, **L''écologie est une question de bon sens**, *Ecology is a question of common sense*, or the ability to perceive something: **Il a un grand sens de l''humour**, *He has a great sense of humour*. But **sens** can also relate to direction: **Vous n''allez pas dans le bon sens**, *You''re not going the right way*. When buying a train ticket, you can select a seat that faces forward: **dans le sens de la marche**, literally "the direction of walking," i.e. movement.', 8),
(44, 6, 'The suffix **-age** can be added to the root of some verbs to make a substantive noun. Thus **composter** means *to time-stamp or punch a ticket*, hence the noun **le compostage**: *time-stamping/punching*. (Context is all-important here, because the verb also means *to compost*!) Likewise, **afficher**, *to display* gives us **l''affichage**, *display or billposting*.', 9),
(44, 7, '**marre**, which is loosely related to **la mer**, *the sea* and hence the sense of discomfort or irritation brought on by sea-sickness, is found in the idiomatic expression **en avoir marre**, *to be fed up*. This can be used simply as an exclamation **J''en ai marre !**, *I''m fed up!*, *I''ve had enough!* or with a direct object: **Il en a marre de son travail**, *He''s fed up with his job*. (Being idiomatic, the expression uses both the indirect object - **son travail** - and the pronoun **en**, which would usually replace it.)', 16),
(44, 8, 'The adjective **faux** (fem. **fausse**) has several meanings, all related to things that are incorrect, fake or false. For example, **un faux billet** is a *forged ticket or forged bank note* while, in music, **une fausse note** is a *wrong note*. The expression **C''est faux** means *It''s wrong* or *a falsehood*. Remember, however, that to be wrong is **avoir tort** (see lesson 28).', 17),
(44, 9, 'The opposite of **être d''accord avec**, *to agree with* is **ne pas être d''accord avec**, *to disagree with*. **Je ne suis pas d''accord avec vous**, *I disagree with you*. It''s simple!', 18),
(44, 10, '**vaut** is the third person singular of the irregular **valoir**, *to be worth*: **je vaux, tu vaux, il/elle vaut, nous valons, vous valez, ils/elles valent**. **Combien vaut ce tableau ?** *How much is this painting worth?* We will see this important verb in greater detail in another lesson.', 18),
(44, 11, '**mal** can be an adverb meaning *badly* (lesson 30 line 2) as well as a noun, meaning *pain* or *sickness*, used in the invariable expression **avoir mal à** (lesson 24 line 3). It can also be used figuratively, with **du**: **J''ai du mal à le comprendre**, *I have difficulty understanding him*. (Remember that the plural is **maux**, lesson 32 note 8). The expression **prendre son mal en patience** is equivalent to *grin and bear it* (note that the possessive adjective agrees with the "suffering" person: **je prends mon mal / tu prends ton mal en patience**, etc.)', 18),

(45, 1, 'Most adjectives ending in **-al**, including **social** and **royal**, form their masculine plural with **-aux**: **sociaux**, **royaux**, etc. The feminine forms, **sociale**, **royale**, simply take an **-s** (**sociales**, **royales**). (**Un réseau**, *a network*, forms its plural with an **-x**, as explained in lesson 29 note 9.)', 1),
(45, 2, '**entendu**, the past participle of **entendre**, *to hear* (lesson 40 note 1), can be used as a response, meaning *Of course* (lesson 38 line 12). The phrase **Bien entendu** has the same meaning but is more flexible and can be placed at the beginning, middle or end of a complete sentence: **Bien entendu, nous comprenons votre décision**, *Of course, we understand your decision*.', 2),
(45, 3, '**qui** and **que** are relative pronouns that can refer both to people and to things, **qui** as the subject and **que** as the direct object. It is important not to translate **qui** systematically as *who* because the subject can be inanimate: **Prenez le bus qui part à dix heures**, *Take the bus that leaves at ten o''clock*.', 3),
(45, 4, 'We know the noun **un emploi**, *a job* (lesson 20 line 8). Two related words are **un métier**, which, in addition to an occupation, can also mean a *trade* or *craft*, and **une profession**, *a profession*. (French also uses **un job**, meaning a low-skilled and/or low-paid...job! Please avoid.) The opposite, unemployment, is **le chômage** (line 16). **Être au chômage**, *to be unemployed*.', 6),
(45, 5, '**ce qui** and **ce que** are indefinite pronouns meaning *which* or *what*. They introduce a subordinate clause, in the same way as **qui** and **que**, but are used in sentences where the noun or phrase referred to by a pronoun is not expressed.', 7),
(45, 6, '**voudrais** is the first person singular of the conditional form of **vouloir**: **je veux -> je voudrais**, *I want -> I would like*.', 7),
(45, 7, 'Masculine job titles ending in **-eur** that are derived directly from a verb have a feminine form ending in **-euse** - for example, **un programmeur** (from the verb **programmer**) becomes **une programmeuse** - whereas **-eur** nouns that do not come from a verb stem have the feminine ending **-trice**: **un concepteur / une conceptrice**.', 8),
(45, 8, 'The invariable phrase **pas mal de** is useful for describing a fairly large quantity: **Il y a pas mal de neige ici en janvier**, *There''s quite a lot of snow here in January*. Despite the adjective **mal**, *bad*, the term is not pejorative.', 9),
(45, 9, '**aussi... que** is the comparative of equality, equivalent to *as... as*: **Il est aussi grand que son père**, *He''s as tall as his father*. The second noun can be replaced by a stressed pronoun (but never a subject pronoun, as in English: **Elle est aussi surprise que moi**, *She''s as surprised as I [am]*).', 10),
(45, 10, 'We know that French verbs do not have a progressive form. Where necessary, though, the expression **en train de**, followed by an infinitive, allows us to insist on the ongoing nature of an action: **Je ne peux pas venir, je suis en train de regarder le match**, *I can''t come, I''m watching the game*. The important element is duration: **Voici une bonne adresse pour votre prochain voyage ou votre voyage en cours si vous êtes en train de voyager**, *Here''s a good address for your next trip or your current trip if you are in the process of travelling*. Don''t confuse **en train de** with **en train**, *by train!*', 11),
(45, 11, 'The compound verb **vouloir dire** ("to want to say") translates as *to mean*, i.e. to imply or indicate. Only **vouloir** is conjugated. **Qu''est-ce que tu veux / vous voulez dire ?** *What do you mean?* However, in the sense *to denote*, we use the verb **signifier** (the origin of *to signify*). **Que signifie ce mot?** *What does this word mean?*', 16);

INSERT INTO contents (course_id, seq, french, english) VALUES
(46, 1, 'J''ai perdu mon mari, monsieur l''agent. Il a disparu.', 'I''ve lost my husband, officer (mister the agent). He has disappeared.'),
(46, 2, 'Quand l''avez-vous vu pour la dernière fois ?', 'When did (have) you see him for the last time?'),
(46, 3, 'Hier matin. Nous sommes partis ensemble pour faire les courses.', 'Yesterday morning. We left together to go shopping.'),
(46, 4, 'Moi, je suis allée à l''hypermarché près du Boulevard périphérique et lui est allé à la boulangerie.', '(Me) I went to the hypermarket near the Boulevard Périphérique (peripheral) and (him) he went to the bakery.'),
(46, 5, 'Et depuis, je n''ai aucune nouvelle, même pas un petit coup de téléphone.', 'And since [then] I''ve had no news, not even a little phone call.'),
(46, 6, 'Pouvez-vous décrire votre époux, s''il vous plaît ?', 'Can you describe your husband (spouse), please?'),
(46, 7, 'Il a une quarantaine d''années, mince et assez grand; environ un mètre quatre-vingt-cinq.', 'He''s about 40, thin and quite tall-about 1 metre 85.'),
(46, 8, 'Un visage carré avec des cheveux bruns, longs et raides, et des lunettes noires.', 'A square face with brown hair, long and straight, and dark (black) glasses.'),
(46, 9, 'Comment est-il habillé ? En costume ? En jean ?', 'How is he dressed? In [a] suit? In jeans?'),
(46, 10, 'Il porte un pantalon gris et une chemise à manches courtes, une écharpe et une veste en cuir marron.', 'He''s wearing a [pair of] grey trousers and a short-sleeved shirt, a scarf and a brown leather jacket.'),
(46, 11, 'Oh, et des chaussures noires et des chaussettes assorties.', 'Oh, and black shoes with matching socks.'),
(46, 12, 'Voilà une description vraiment détaillée, meilleure qu''une photographie !', 'That''s a really detailed description, better than a photograph!'),
(46, 13, 'Je peux faire mieux : j''ai un petit film sur mon téléphone. Vous voulez le voir ?', 'I can do better: I have a little film on my phone. Do you want to see it?'),
(46, 14, 'Non, ce n''est pas la peine. Vous le décrivez très bien. Mieux que moi !', 'No, don''t bother (this is not the difficulty). You describe him very well. Better than me!'),
(46, 15, 'J''ai l''habitude de le perdre: il déteste faire du shopping et il disparaît une fois sur deux.', 'I''m used (I have the habit) to losing him: he hates shopping and disappears half of the time (one time on two).'),
(46, 16, 'Mais cette-fois-ci je suis vraiment inquiète car il avait une grande valise dans une main et un billet d''avion dans l''autre.', 'But this time, I''m really worried because he had a big suitcase in one hand and a plane ticket in the other.'),
(46, 17, 'Aucun souci : nous allons faire de notre mieux pour le retrouver.', 'No worries: we''re going to do (of) our best to find him.'),

(47, 1, 'J''ai un service à te demander: peux-tu nous aider à déménager samedi et dimanche prochains ?', 'I have a favour (service) to ask you: can you help us to move [house] next Saturday and Sunday?'),
(47, 2, 'Je vais aussi demander à Stéphane et à Olivier: plus on est nombreux, plus on s''amuse.', 'I''m also going to ask Stéphane and Olivier: the more, the merrier (more we are numerous, more we amuse-ourselves).'),
(47, 3, 'Tu vas leur demander de travailler un samedi ? Bonne chance! Ce sont de gros paresseux.', 'You''re going to ask them to work on a Saturday? Good luck, they''re (big) slackers.'),
(47, 4, 'Tu pourrais éventuellement parler à Didier, mon beau-frère: il a une entreprise de déménagement.', 'You could maybe (possibly) talk to Didier, my brother-in-law (handsome-brother): he has a removal firm.'),
(47, 5, 'Est-ce que tu peux lui parler, toi? Je ne le connais pas. Tu penses qu''il peut le faire gratuitement ?', 'Can you ask him (you)? I don''t know him. Do you think he can do it free of charge (freely)?'),
(47, 6, 'J''en doute, car ses affaires vont mal, mais je peux toujours essayer. Je te tiens au courant. [...]', 'I doubt it, because his business (are) is going badly. But I can always ask him. I''ll keep you posted (in the current). [...]'),
(47, 7, 'Mon beau-frère est d''accord pour t''aider. Je lui ai dit que tu es un de mes meilleurs amis.', 'My brother-in-law agrees to help you. I told him that you''re one of my best friends.'),
(47, 8, 'En plus, il est aimable: il te facture seulement la location du camion et une demi-journée de travail.', 'What''s more, he''s nice: he''s charging (invoicing) you only [for] the rental of the lorry and a half-day''s work.'),
(47, 9, 'En gros, cela te fait quelques centaines d''euros, au lieu de mille ou plus, son tarif normal.', 'All in all (in fat), that makes (you) a few hundred euros, instead of a thousand or more, his normal rate.'),
(47, 10, 'Il est très bien, ce Didier! C''est très gentil de sa part. Tu peux le remercier ?', 'He''s great (very good), (that) Didier! It''s very kind of him (from his part). Can you thank him?'),
(47, 11, 'Tu peux lui dire toi-même: il arrive dans une heure et demie avec un collègue. On va les attendre. [...]', 'You can say it yourself: he''s arriving in an hour and a half with a colleague. We''re going to wait for them. [...]'),
(47, 12, 'Maintenant, au boulot. Tout ce qui est gros et lourd va dans le camion de Didier:', 'Now, let''s get cracking (to work). Everything that''s big and heavy goes in Didier''s lorry:'),
(47, 13, 'le canapé, les fauteuils, les lits, les armoires, la machine à laver, le lave-vaisselle et la cuisinière.', 'the sofa, the armchairs, the beds, the wardrobes, the washing machine, the dishwasher and the stove.'),
(47, 14, 'Le reste la vaisselle, les tableaux, la télé, le linge, les rideaux,', 'The rest-the dishes, the paintings, the TV, the linen, the curtains,'),
(47, 15, 'les cartons dans l''escalier et les piles de bouquins contre le mur -', 'the boxes on ( ) the stair[s] and the piles of books against the wall-'),
(47, 16, 'on le prend avec nous dans la camionnette. Je vais la chercher tout de suite.', 'we''re taking it with us in the van. I''m going to fetch (look for) it right away.'),
(47, 17, 'Bon courage à tout le monde: on a une longue journée devant nous.', 'Best of luck everyone (good courage): we have a long day ahead of (before) us.'),
(47, 18, 'Plus vite on finit, plus vite on peut se coucher.', 'The quicker we finish, the quicker we can go to bed (more fast one finishes, more fast one can lie down).'),

(48, 1, 'Comme il fait chaud aujourd''hui, nous allons pique-niquer dans la forêt de Fontainebleau.', 'As it''s warm (hot) today, we''ll [go for a] picnic in the Fontainebleau forest.'),
(48, 2, 'Honnêtement, un pique-nique ne me dit rien. C''est tellement inconfortable.', 'Honestly, I don''t feel like a picnic. It''s so uncomfortable.'),
(48, 3, 'On est mal assis par terre et on mange mal : les chips, les salades de riz dégoûtantes,', 'You''re seated uncomfortably (badly) on the ground and you eat badly: crisps, disgusting rice salads,'),
(48, 4, 'des sandwichs de poulet sans goût, les bananes trop mûres et des fourmis et des guêpes partout.', 'chicken sandwiches with no taste, over-ripe bananas -and ants and wasps everywhere.'),
(48, 5, 'Et puis on a du mal à manger proprement, avec les assiettes en papier, les gobelets en carton,', 'And then it''s hard to eat cleanly, with paper plates, cardboard beakers,'),
(48, 6, 'les fourchettes en plastique et les couteaux qui ne coupent rien.', 'plastic forks, and knives that don''t cut anything.'),
(48, 7, 'Bref, je ne supporte pas les pique-niques.', 'In short (brief), I can''t stand (support) picnics.'),
(48, 8, 'Mais ce n''est pas vraiment une mauvaise idée, tu sais. Au contraire.', 'But it''s not really a bad idea, you know. On the contrary.'),
(48, 9, 'D''abord, c''est nous qui allons préparer la nourriture, avec de bons produits sains.', 'First, it''s us who are going to prepare the food, with good, healthy produce.'),
(48, 10, 'Ensuite, pas de problème de confort. Regarde ceci : c''est notre nouveau panier à pique-nique.', 'Next, no comfort problems. Look at this: it''s our new picnic hamper (basket).'),
(48, 11, 'Mais ce n''est pas un panier, c''est un sac à dos !', 'But it''s not a basket, it''s a backpack!'),
(48, 12, 'Oui, mais c''est un sac à dos de luxe! Il y a tout ce qu''il faut pour faire de vrais repas.', 'Yes, but a luxury backpack! There''s everything you need for (to make) a good meal.'),
(48, 13, 'Des couverts en métal, des assiettes en porcelaine, et des verres à vin et à eau.', 'Metal cutlery, china (porcelain) plates, water and wine glasses.'),
(48, 14, 'Et regarde cela. Qu''est-ce que tu en penses ?', 'And look at that? What do you think (of it)?'),
(48, 15, 'Qu''est-ce que c''est ?', 'What is it?'),
(48, 16, 'C''est un sac spécifique pour les bouteilles de vin blanc. Sophistiqué, non ?', 'It''s a special bag for bottles of white wine. Sophisticated, isn''t it (no)?'),
(48, 17, 'On a aussi quatre chaises pliantes, une table basse et une vraie couverture.', 'We also have folding chairs, a low table and a real blanket.'),
(48, 18, 'Mais attends, qu''est ce qui se passe? La pluie commence à tomber.', 'But hang on (wait), what''s happening? The rain is starting to fall.'),
(48, 19, 'Oh, il pleut. Quel dommage! Pas de pique-nique aujourd''hui...', 'Oh, it''s raining. What [a] pity! No picnic today');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(46, 1, 'In formal language, **monsieur** and **madame** (but not **mademoiselle**) are used, along with an honorific, when addressing someone in an official position: **monsieur le député**, ("mister member of parliament") **madame la directrice**, ("madam director"). (**Un agent de police**, *a police officer*, though masculine, **l''agent** can apply to officers of both sexes). Likewise, **un époux / une épouse**, *a spouse*, is used in official contexts, instead of **un mari / une femme**, to mean *a husband / a wife*.', 1),
(46, 2, 'Remember that the past participle of verbs forming their perfect tense with **être** (lesson 43 note 3) agrees in number and gender with the subject, not the object, of the sentence. If a plural subject comprises both a male and a female agent, as here, then the masculine takes precedence - an issue we will discuss in greater detail later on.', 3),
(46, 3, 'The stressed pronouns **moi, toi, lui, elle, nous, vous, eux** and **elles** are used for emphasis, especially when a contrast is involved: **Moi, j''aime le café au petit-déjeuner, mais lui préfère le thé**. In this context, the pronouns do not necessarily need to be translated into English: *I like coffee for breakfast but he prefers tea*. Note how the stressed pronoun is followed immediately by a subject pronoun (the second clause in our example could be phrased ...**mais lui, il préfère le thé**, in order to add even greater emphasis).', 4),
(46, 4, '**aucun** is a useful adjective and pronoun, meaning *not any, no, or none*. As a determiner, it is not used in the plural (it comes from Old French, meaning "not one") and, in a negative construction, is not followed by **pas**: **Ils n''ont aucun problème de santé**, *They have no health problems*. It must, however, agree with the singular noun it determines: **Je n''ai aucune idée**, *I have no idea*. In informal language, a sentence with the negative is often shortened: **Aucune idée**.', 5),
(46, 5, 'A number of nouns are plural in French but singular in English. We already know **les toilettes**, *the toilet* (lesson 15 note 6), and **en vacances**, *on holiday* (lesson 18 line 9), another one is **les cheveux**, *hair*. **Tes cheveux sont trop longs**, *Your hair is too long*. The singular **un cheveu** is used in certain expressions, such as **avoir un cheveu sur la langue** ("to have a hair on the tongue"), *to have a lisp*, but rarely in the physical meaning of a hair.', 8),
(46, 6, 'In contrast to note 5, some nouns are plural in English but singular in French. This rule applies in particular to "two-legged" garments, which can be singularised in French: **un jean**, *a pair of jeans*, **un pantalon**, *a pair of trousers*. Logically, the plural *two pairs of trousers* is translated as **deux pantalons**.', 9),
(46, 7, '**meilleur**, the comparative form of **bon** (lesson 42 section 3), is an adjective and therefore agrees with its noun: **J''ai une meilleure idée**, *I have a better idea*. **Ce café sert les meilleures crêpes et les meilleurs gâteaux de Bretagne**, *This café serves the best pancakes and the best cakes in Brittany*. Don''t confuse **meilleur** with **mieux**, the comparative adverb of **bien**, *well* (see lesson 42 section 3): **Comment va ton frère? - Il va mieux**.', 12),
(46, 8, 'The abstract noun **la peine** has several meanings, ranging from sadness to difficulty (though not pain, despite the etymological link). **Ce n''est pas la peine** is an idiomatic expression meaning something like *Don''t bother* or *Don''t worry about it*. **Vous voulez de l''aide ? - Ce n''est pas la peine, merci**. *Do you want help? - Don''t bother, but thanks*. In a full sentence, the expression is followed by the preposition **de**. **Ce n''est pas la peine de chercher du sucre, il n''y en a plus**. *There''s no point looking for sugar, there''s none left*.', 14),
(46, 9, 'Here''s another idiomatic expression. **Un souci** is *a concern, a worry*. The common interjection **Aucun souci** is the equivalent of *No problem* or *Don''t worry about it*. An even commoner form (and arguably the back translation of the Anglo-Australian *No worries*) is **Pas de souci(s)**, in which case the noun can be in the plural.', 17),

(47, 1, 'The English comparative phrase *the more ... the more* has a direct equivalent in French: **plus... plus**. Typically, this type of construction uses the impersonal pronoun **on**: **Plus on gagne de l''argent, plus on dépense**, *The more money you earn, the more you spend*. (Another well-known saying, **Plus on est de fous, plus on rit** - literally "The more madmen there are, the more we laugh" - is the equivalent of *The more, the merrier*.)', 2),
(47, 2, '**ce** is both a singular demonstrative adjective (lesson 9 note 1) and a demonstrative pronoun. It can replace **il/elle est** (**c''est**) but also **ils/elles sont**, (**ce sont**), in which case it is translated by *they*. **Ce sont deux de mes films préférés**, *They are two of my favourite movies*. The differences between **il/elle est** (**ils/elles sont**) and **c''est** (**ce sont**) are quite complex but, in this case, **c''est / ce sont** describes a situation ("they''re lazy") as opposed to the specific person or object.', 3),
(47, 3, 'As we know, **gros/grosse** means *fat* (lesson 14 section 5.2). But it has a much broader meaning, including *big* (lesson 19 line 11), *thick* (**un gros manteau**, *a thick coat*), and *serious* (**une grosse erreur**, *a serious mistake*). To translate the adjective properly or find an idiomatic equivalent, always check the noun it is qualifying: **Tu es un gros paresseux!** *You''re a slacker / a lazybones!* The expression **en gros**, usually placed at the beginning of a sentence or clause, means *broadly, basically*, etc.', 9),
(47, 4, '**éventuellement** is a faux-ami. It expresses the idea of possibility. **Je ne connais pas la réponse, mais vous pouvez éventuellement la trouver en ligne**, *I don''t know the answer but you may be able to find it online*. **Nicole vient à la fête demain ? - Éventuellement**, *Is Nicole coming to the party tomorrow? - Maybe*. (The adjective is **éventuel**, *possible*). The adverb *eventually* is rendered **finalement** or **enfin**: **Il a finalement acheté une nouvelle collection de timbres**, *He eventually bought a new stamp collection*.', 4),
(47, 5, '**courant** is both a noun and an adjective: **le courant** means *the current* (water, electricity, etc.), while the adjective means *ordinary, standard, common*, etc. (but not *current* - another faux-ami!). **C''est un problème courant**, *It''s a common problem*. The expression **être au courant**, first seen in lesson 32, means *to be aware of something*. **Ma belle-sœur arrive demain. - Oui, je suis au courant**. *My sister in law is arriving tomorrow. - Yes, I''m aware of that*. **Tenir au courant**, *to keep someone informed/posted*.', 6),
(47, 6, 'Some verbs have no direct equivalent in other languages. That is the case for *to charge* (money). The most convenient equivalent is probably **facturer**, *to invoice*: **Le plombier m''a facturé six cents euros de l''heure**, *The plumber charged me 600 euros an hour*. Another possibility is **prendre**, *to take*, usually with a monetary amount or an adjective: **Combien prend-il pour une leçon privée ?** *How much does he charge for a private lesson?*', 8),
(47, 7, 'When **demi**, *half*, comes before a noun, it is invariable: **une demi-heure**, **un demi-kilo**. After the noun, however, it can be feminine or masculine depending on the gender - **une heure et demie**, **un kilo et demi** - but never plural. In every case, the pronunciation is identical.', 11),
(47, 8, 'We have seen **bien** used as an adverb meaning *well*, but it can also be an adjective, usually as part of an expression before a noun: **Elle est très bien, cette chanteuse**, *She''s very good, that singer*. In such cases, however, it does not agree with the subject: **Les fauteuils sont très bien**, *The armchairs are very nice*.', 10),
(47, 9, 'We know that indirect object pronouns come before the verb in French (lesson 35 section 5). One slight complication is that some verbs taking an indirect object in English require a direct object in French. Among the most common of these are **chercher**, *to look for, to fetch*, and **attendre**, *to wait for*. In this case, the noun is replaced by a direct object pronoun: **J''attends Didier et son collègue -> Je les attends** (not **Je leur attends**).', 16),
(47, 10, '**le boulot** is a familiar but very common word for *work*, for which there is no one-on-one equivalent. Unlike its English counterpart, the noun is both countable and uncountable. **J''ai beaucoup de boulot en ce moment**, *I''ve got a lot of work at the moment*, **Jeanne commence son nouveau boulot ce lundi**, *Jeanne is starting her new job this Monday*. The imperative expression **Allez, au boulot !** means something like: *Let''s get cracking!* Another slang word that has no equivalent is **un bouquin**, *a book*, line 15, used in a familiar register in the same way as **un livre**.', 12),

(48, 1, 'We have already seen **dire** used idiomatically to mean *to fancy, like*, etc. (lesson 25 note 5). A related expression, **Ça ne me dit rien**, expresses a lack of interest or enthusiasm: **Tu veux venir au cinéma avec nous ? - Ça ne me dit rien**, *Do you want to come to the movies with us? - I don''t feel like it*. As in our example (line 2), **ça** can be replaced by a noun. The same structure can also express a lack of recognition or familiarity: **Ce nom ne me dit rien**, *I''m not familiar with that name*.', 2),
(48, 2, 'When describing temperature conditions, French does not use the same verbs as English. We already know **avoir chaud** and **avoir froid** (lesson 26 note 3). Likewise, **faire chaud/froid** describes the ambient temperature: **Il y a une grande différence de température dans cette région de France, il fait très chaud en été et il fait très froid en hiver**, *There is a big difference in temperature in this region of France, it is very hot in summer and very cold in winter*. When talking about the weather, **chaud** by itself can mean both *hot* and *warm*.', 1),
(48, 3, 'Like **bien** (lesson 47 note 8), **mal** is usually an adverb: **Je dors mal quand il fait chaud comme ça**, *I sleep badly when it''s hot like that* - but it can sometimes be used as an adjective. In this case, it is usually invariable and can only be used with state-of-being verbs like **être**: **Je n''ai rien fait de mal**, *I haven''t done anything wrong*. Don''t confuse **mal** with the adjective **mauvais(e)**: **C''est une mauvaise idée**, *It''s a bad idea*. And don''t confuse **avoir mal**, *to feel pain*, (lesson 32 line 12) with the idiomatic expression **avoir du mal** (lesson 44 note 11).', 3),
(48, 4, 'Remember that the adjective describes the head noun, in this case **une salade**, and not the complement, **de riz**. It therefore has to agree in the feminine plural. For example, **une salade de fruits délicieuse**, *a delicious fruit salad*. This rule applies to all such compound nouns. (Note that English, which has no grammatical genders, is less precise than French in this respect: does *delicious* apply to fruit, salad or both? If we want to insist on the first noun, we would have to say *a salad of delicious fruit*, whereas French makes the distinction through adjective agreement: **une salade de fruits délicieux**.)', 3),
(48, 5, 'The preposition **en** is used between two nouns to describe what the first object is made of: **une assiette en carton**, *a cardboard plate*, **deux tasses en porcelaine**, *two china cups*, etc.', 5),
(48, 6, '**supporter**, *to support*, also means *to tolerate*. The verb is often used idiomatically in the negative: **Je ne supporte pas cette émission**, *I can''t stand that show*.', 7),
(48, 7, 'When a BAGS adjective (lesson 14 section 5.2) comes before a plural noun, the partitive article **des** becomes **de** (or **d''** before a vowel). For example, **Nous achetons des produits sains**, *We buy healthy produce*, but **Nous achetons de bons produits sains**, *We buy good healthy produce*.', 9),
(48, 8, '**Ceci** and **cela** (line 14) are demonstrative pronouns meaning *this, that*, and, in impersonal sentences, *it*. **Ceci** is not widely used in everyday language, except when referring to something that is about to be mentioned or presented: **Écoutez ceci et dites-moi ce que vous en pensez**, *Listen to this and tell me what you think*. **Cela** (lesson 47 line 9) is usually abbreviated to **ça** in informal language: **Ça te fait quelques centaines d''euros...**', 10),
(48, 9, '**à** is used in compound nouns to indicate the purpose of a designated object, whereas English strings two nouns together: **un panier à pique-nique**, *a picnic basket*, **un sac à dos**, *a backpack* ("a bag to the back"). Likewise, **un verre à eau**, *a water glass*, etc. Be careful not to confuse **à** with **de** (*of*) in this type of noun: **un verre à vin**, *a wine glass*, **un verre de vin**, *a glass of wine*. The difference can be disappointing...', 10),
(48, 10, '**passer** means *to pass*, which we have seen in lesson 40 line 12, as well as in the idiom **passer un coup de fil** (lesson 41 note 4). But **se passer** (literally "to pass oneself") is a reflexive verb, which we will study in the next set of lessons. In this context, the idiom **se passer** means *to happen*: **Qu''est-ce qui se passe ?**, *What''s happening? / What''s going on?*', 18);

INSERT INTO contents (course_id, seq, french, english) VALUES
(50, 1, 'Que faites-vous dans la vie ?', 'What do you do for a living (in life)?'),
(50, 2, 'Je m''ennuie. Tous les jours, sans exception, je fais exactement la même chose.', 'I get bored. Every day, without exception I do exactly the same thing.'),
(50, 3, 'Je me réveille à la même heure et je me connecte à Internet pour lire les messages dans ma boîte de réception.', 'I wake up at the same time and I log on (connect myself) to [the] internet to read the messages in my inbox (box of receipt).'),
(50, 4, 'Si j''ai vraiment envie, j''écoute les informations à la radio ; je me méfie des journaux télévisés', 'If I really want to (have envy), I listen to the news on the radio; I''m wary of TV news broadcasts'),
(50, 5, 'car je trouve qu''ils se trompent constamment et, de toute façon, les infos me dépriment.', 'because I find that they constantly get things wrong (mistake themselves) and, in any case, the news depresses me.'),
(50, 6, 'Moins on les écoute, plus on est tranquille.', '[the] less you listen to it, [the] calmer you feel.'),
(50, 7, 'De temps à autre, je lis un magazine sur ma tablette, mais je le finis en cinq minutes.', 'From time to time (time to other), I read a magazine on my tablet, but I finish it in five minutes.'),
(50, 8, 'Au bout d''un quart d''heure, je me lève très lentement - je ne me dépêche pas -', 'After (at the end of) half an hour, I get up (raise myself) very slowly - I don''t hurry (myself) -'),
(50, 9, 'puis je vais dans la salle de bains, où je me rase, me lave et me brosse les dents.', 'then I go into the bathroom, where I shave (myself), wash (myself), and brush (brush myself the) my teeth.'),
(50, 10, 'Ensuite je m''habille et me prépare à partir au travail, en centre-ville.', 'Then I get dressed and prepare to leave for work, in the town centre.'),
(50, 11, 'J''y vais en voiture, jamais en bus ou en métro, et j''y suis en vingt minutes.', 'I go by ( ) car, never by (in) bus or by (in) metro, and I''m there in twenty minutes.'),
(50, 12, 'En arrivant, je m''installe dans mon bureau et ferme la porte à clé.', 'When I arrive (on arriving), I settle (install myself) in my office and lock the door.'),
(50, 13, 'Je fais semblant de travailler, mais j''essaie surtout de ne pas m''endormir.', 'I pretend (make semblance) to work, but I try above all not to fall asleep.'),
(50, 14, 'Le travail, c''est dur, vous savez. Je me demande si je suis fait pour ça.', 'Work is very hard, you know. I wonder (ask myself) whether I''m made for it.'),
(50, 15, 'C''est très stressant de ne rien faire. Je dois me détendre autant que possible.', 'It''s very stressful doing nothing. I must relax as much as possible.'),
(50, 16, 'Mon médecin m''a conseillé de ne pas m''énerver et de me reposer quand je peux.', 'My doctor advised me not to get annoyed (annoy myself) and to rest (repose myself) when I can.'),
(50, 17, 'Mais vous vous amusez quand même un peu ? En fait, quel métier faites-vous ?', 'But you enjoy yourself a little anyway? In fact, what job do you do?'),
(50, 18, 'Je suis Président-directeur général d''une des entreprises de mon père.', 'I''m Chairman and Managing Director of one of my father''s companies.'),
(50, 19, 'Ça ne m''étonne pas !', 'That doesn''t surprise me.'),

(51, 1, 'Tout le monde est là ? Non, il manque Brice. Où est-il ?', 'Is everyone there? No, (it misses) Brice is missing. Where is he?'),
(51, 2, 'Toujours au lit, mais ne l''attendons pas. Tu sais très bien qu''il ne se lève jamais avant midi.', 'Still in bed, but let''s not wait [for] him. You know very well that he never gets up before noon.'),
(51, 3, 'Dépêchons-nous ! Nous perdons du temps.', 'Let''s hurry up! We''re wasting (losing) time.'),
(51, 4, 'La pièce commence dans vingt minutes et nous allons manquer le début.', 'The play starts in twenty minutes and we''re going to miss the beginning.'),
(51, 5, 'On n''est pas encore prêts et le théâtre n''est pas tout près. Comment faire ?', 'We''re not yet ready and the theatre isn''t (very) close [by]. What shall we do?'),
(51, 6, 'Il est trop tard pour y aller en transports en commun, donc on va prendre la voiture.', 'It''s too late to go there by public transport (in common), so we''re going to take the car.'),
(51, 7, 'Nous y serons en dix minutes si nous partons dans deux minutes.', 'We''ll be there in ten minutes if we leave in two minutes.'),
(51, 8, 'Tu plaisantes! On n''a pas le droit de se garer dans les rues autour du centre.', 'You''re joking! You''re not allowed to park in the streets around the centre.'),
(51, 9, 'Ne vous inquiétez pas : c''est facile comme tout.', 'Don''t worry: it''s as easy as anything (all).'),
(51, 10, 'Je m''arrête dix secondes dans une place de livraison mais je n''arrête pas le moteur.', 'I stop in a delivery space but I don''t turn off (stop) the engine.'),
(51, 11, 'Vous descendez vite et je vais garer la voiture dans le parking public qui se trouve du côté droit du tribunal.', 'You get out quickly and I go to park the car in the public carpark (that is located) on the right side of the court [house].'),
(51, 12, 'Pendant ce temps, vous achetez les billets et on se retrouve dans le foyer.', 'Meanwhile (during this time), you buy the tickets and we meet up in the foyer.'),
(51, 13, 'Bon, on y va. Bougez-vous !', 'Right, let''s go (one there goes). Move (yourselves)!'),
(51, 14, 'Euh, attendez un instant. Il y a un petit problème.', 'Um, wait a moment (instant). There''s a slight problem.'),
(51, 15, 'Qu''est ce qui se passe ? Nous allons être en retard!', 'What''s happening? We''re going to be late!'),
(51, 16, 'Je ne trouve pas mes clés de voiture.', 'I can''t (don''t) find my car keys.'),
(51, 17, 'Je ne me souviens pas où je les ai mises. Elles ne sont pas dans ma poche,', 'I don''t remember where I put them. They''re not in my pocket,'),
(51, 18, 'ni dans le tiroir du meuble en bas de l''escalier, où je les mets d''habitude.', 'nor in the drawer of the piece of furniture at the bottom of the stairs, where I usually put them.'),
(51, 19, 'Pourquoi souris-tu ?', 'Why are you smiling?'),
(51, 20, 'Parce qu''elles sont dans ta main, idiot! Vite, dépêche-toi. En route !', 'Because they''re in your hand, dummy! Quick, hurry up. Let''s get moving (on road)!'),

(52, 1, 'J''ai accepté de répondre à un sondage sur "les attentes des Français dans le domaine de l''audiovisuel".', 'I''ve agreed (accepted) to answer a survey (sounding) on "the expectations of the French in the field of broadcasting (audiovisual)"'),
(52, 2, 'Voulez-vous participer ou, au moins, donner votre point de vue sur cette première question :', 'Do you want to take part or, at least, give your point of view on this first question:'),
(52, 3, '"Quelle est votre série préférée, celle qui vous a fait rire ou pleurer le plus ?"', '"What is your favourite series, the one (that) which made you laugh or cry the most?"'),
(52, 4, 'La mienne est l''émission d''humour "Puissance faible".', '(The) mine is the comedy show (programme of humour) "Low (weak) Power."'),
(52, 5, 'Et la tienne, Mathilde? La vôtre, Léon et Adèle ?', 'And (the) yours, Mathilde? (The) yours, Léon and Adèle?'),
(52, 6, 'Moi, je ne suis pas fan de séries. Je préfère les magazines et les documentaires.', 'Me, I''m not a fan of series. I prefer magazine [programmes] and documentaries.'),
(52, 7, 'Et vous deux, vous préférez les divertissements ou les débats politiques ?', 'And you two, do you prefer entertainment [shows] or political debates?'),
(52, 8, 'Ni l''un ni l''autre. Nous regardons la télévision pour nous distraire, pas pour nous instruire !', 'Neither one nor the other. We watch television for entertainment (to entertain ourselves) not education (to instruct ourselves)!'),
(52, 9, 'C''est vrai mais j''ai quand même un faible pour les concours de cuisine.', 'It''s true, but even so I have a soft spot (weak) for cooking contests.'),
(52, 10, 'Pour moi, la meilleure émission de tous les temps est "Bon appétit !".', 'For me, the best show ever (of all the times) is "Enjoy Your Meal!" (Good appetite!)'),
(52, 11, 'Vous vous en souvenez? Avec Maïka, la présentatrice célèbre, celle avec l''accent basque.', 'Do you remember it? With the famous compere Maïka, the one (that) with the Basque accent.'),
(52, 12, 'La femme maladroite qui s''est coupé la main plusieurs fois en faisant la cuisine ?', 'The clumsy woman who cut her finger several times (in) while cooking (making the cooking)?'),
(52, 13, 'C''est bien elle. En fait, elle s''est coupée une fois seulement, mais tout le monde s''en souvient.', 'That''s the one. In fact, she cut herself only once, but everyone remembers it.'),
(52, 14, 'L''émission s''est arrêtée il y a dix ans après huit saisons. Je l''ai regardée du début à la fin,', 'The show ended (stopped itself) ten years ago after eight seasons. I watched it from the beginning to the end,'),
(52, 15, 'et je ne me suis jamais ennuyée un seul instant. Chère Maïka, vous me manquez !', 'and I never got bored for a single moment. Dear Maïka, I miss you (you me are missing)!'),
(52, 16, 'Oui, nous nous sommes bien amusés, à l''époque. Maintenant, tout est en ligne.', 'Yes, we really enjoyed ourselves at the time. Now, everything is online.'),
(52, 17, 'Je vais écrire ça sur la feuille de réponse.', 'I''m going to write that on the answer sheet.'),
(52, 18, 'Zut, mon stylo ne marche plus. Prête-moi le tien, s''il te plaît Mathilde.', 'Damn, my pen doesn''t work anymore. Lend me (the) yours, please Mathilde.'),
(52, 19, 'Tu peux prendre le nôtre si tu veux. C''est amusant, ce petit jeu! Continuons.', 'You can take (the) ours if you want. This little game is fun! Let''s continue.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(50, 1, 'This lesson looks at pronominal verbs and, more specifically, reflexive verbs, where the subject is the person or thing performing the action. Indicated by **se** (or **s''** in the infinitive **s''ennuyer**, for example), these verbs always take reflexive pronouns in French, though not necessarily in English. Thus the transitive verb **ennuyer quelqu''un**, *to bore someone*, requires a pronoun in the reflexive form: **je m''ennuie**, which translates as *I am bored* ("I bore myself") or, in some contexts, *I get bored*. Likewise, **Je connecte mon ordinateur à mon téléphone**, *I''m connecting my computer to my phone*, requires a pronoun if the subject and object are the same person: **Je me connecte à Internet**, *I''m connecting to the internet*.', 2),
(50, 2, '**à** with the definite article (**au** with a masculine noun) translates *on* in the case of communications media such as the TV, radio or phone: **à la radio**, **à la télévision**, **au téléphone**. Be careful not to use **sur**.', 4),
(50, 3, '**se méfier (de)** means *to mistrust* or *be suspicious of*. (It is the negative form of **se fier à**, *to trust*). **Elle se méfie des informations qu''elle lit en ligne**, *She mistrusts the news that she reads online*. (Remember: **de** becomes **des** because **informations** is plural). The imperative **Méfiez-vous !** is commonly used as a warning - **Méfiez-vous du chien !**, *Beware of the dog* - and in certain proverbs: **Il faut se méfier de l''eau qui dort** ("You need to be wary of water that sleeps"), i.e. *Still waters run deep*.', 4),
(50, 4, 'Here is another apocope (lesson 17 note 7): **les informations**, *the news*, is shortened in everyday speech to **les infos**.', 5),
(50, 5, '**me** is one of the reflexive pronouns, along with **te**, **se** (the same as the infinitive), **nous** and **vous**. But it is also a direct object pronoun (lesson 24 note 6). For example, **Je me réveille à midi**, *I wake up at noon*, but **Le bruit me réveille toutes les nuits**, *The noise wakes me every night*.', 5),
(50, 6, '**en**, as we know, can be both an adverbial pronoun (lesson 31 note 2) and a preposition meaning *on, in, to*, etc. Note how it is used in this lesson, and how it contrasts with **dans** (lines 3 and 12). In particular, **en** is used with modes of transport - **en bus**, **en voiture**, etc. - but not for walking: **aller à pied** (lesson 25 line 10). We''ll look at **en** vs. **dans** in greater detail in the next revision lesson.', 11),
(50, 7, 'Many verbs that are reflexive in French but not in English concern everyday actions such as getting up (**se lever**), shaving (**se raser**), dressing (**s''habiller**), brushing one''s teeth (**se brosser les dents**), but also taking a shower (**se doucher**), applying make-up (**se maquiller**) and brushing one''s hair (**se brosser les cheveux**).', 8),
(50, 8, 'See lesson 42 section 1.1', 8),
(50, 9, 'The noun **semblant**, the origin of semblance, is commonly used in the expression **faire semblant (de)**, *to pretend or act as if*. **Mon enfant fait semblant de ne pas m''entendre quand je dis non**, *My child pretends not to hear me when I say no*.', 13),
(50, 10, '**demander (à)**, *to ask*, is used in the pronominal form, **se demander**, to mean *to wonder* ("to ask oneself"): **Je me demande ce qu''il faut faire**, *I wonder what to do*. The verb is rarely used in the negative.', 14),
(50, 11, 'Note that the English idiom *I don''t wonder* means *I''m not surprised* and is translated with the verb **s''étonner** (the root of to astonish): **Ça ne m''étonne pas**, *That doesn''t surprise me*.', 19),

(51, 1, 'We saw **manquer**, *to miss*, in lesson 27 note 2 (and below, in line 4). Here, however, the verb is used in the impersonal form, so **il** can be translated in different ways: **Il manque un mot dans cette phrase**, *There''s a word missing in this sentence*. The pronoun is invariable, even if the subject is plural: **Il manque trois personnes**, *Three people are missing*. Compare this with **Où est-il?**, were **il**, of course, means *he*.', 1),
(51, 2, 'As we saw in the previous lesson, the negative of a reflexive verb is formed by placing the particle **ne** before the pronoun and **pas** (or an adverb, lesson 32 note 5) after the verb: **Je ne me souviens pas où tu habites**, *I don''t remember where you live*, **Ils ne s''arrêtent jamais de travailler!** *They never stop working!*', 2),
(51, 3, 'The imperative form of reflexive verbs depends on whether the sentence is negative or affirmative. In the negative, the pronoun comes before the verb, as usual: **Ne nous inquiétons pas**, *Let''s not worry*. In the affirmative, however, the pronoun comes afterwards: **Dépêchez-vous !** *Hurry up!*. Remember also that **te** becomes **toi** in an affirmative command: **Dépêche-toi !**, but it does not change if the command is negative: **Ne te dépêche pas**.', 3),
(51, 4, '**Comment faire ?** (literally "How to do?") is a useful, short way of asking what to do or how to do something. It can be used alone - **J''ai perdu mon mot de passe. Comment faire ?** *I''ve lost my password. What should I do?* - or with a complement: **Comment faire pour fermer une boîte de dialogue?** *What do you do to close a dialogue box?*', 5),
(51, 5, 'You know some of the differences between **en** and **dans**, summarised in lesson 50. With an expression of time, the difference is quite subtle but very important. While **en** expresses the time taken to do something - **Je peux le faire en cinq minutes**, *I can do it in five minutes* - **dans** indicates when the action takes, or will take, place: **Elle peut le faire dans cinq minutes**, *She can do it in five minutes'' time*. Look again at sentence 7: **en** describes the duration of the trip to the cinema whereas **dans** specifies when that trip will begin.', 7),
(51, 6, '**le droit** means *the law* (lesson 43 line 7) but also *the right* (lesson 20 line 6). Thus the expression **avoir le droit (de)** means *to have the right (to)* but also, in everyday speech, *to be allowed to*: **Vous n''avez pas le droit de vous garer ici**, *You''re not allowed to park here*. (Remember that **droit** is also an adjective, meaning *right*, as opposed to **gauche**, *left*.)', 8),
(51, 7, 'Here is an example of a verb used in the transitive and the reflexive forms: **Où est-ce que tu gares ta voiture ?** *Where do you park your car?* If we drop the direct object of the sentence (i.e., if the subject and object are the same), we use a reflexive: **Où est-ce que tu te gares ?** *Where do you park/Where are you parking?*', 8),
(51, 8, 'Some verbs have a slightly different meaning when used in the reflexive form. In this case, **Je m''arrête** means *I pull up* (in a car, for example) whereas **J''arrête le moteur** means *I turn off the engine*. Similarly, **se trouver** ("to find itself/oneself"), the reflexive form of **trouver**, means more or less the same as *to be*: **Trouville se trouve en face de Deauville**, *Trouville is opposite Deauville*.', 10),
(51, 9, '**retrouver** (literally "to find again") means *to find* something that one has lost. But it is often translated simply by *to find*: **J''ai retrouvé mes clés**, *I''ve found my keys*. The reflexive form generally means *to meet up with*: **On se retrouve au restaurant à vingt heures**, *We''re meeting up at the restaurant at 8pm*.', 12),
(51, 10, 'We know that the pronominal verb **se passer** means *to happen* (lesson 48 note 10). The actual translation will depend on the context, though, and is often very simple: **La fête se passe chez nous demain soir**, *The party is at our place tomorrow evening*.', 15),

(52, 1, '**une attente**, from **attendre**, *to wait*, has a literal meaning, found in terms such as **une salle d''attente**, *a waiting room*, and also in sentences: **L''attente à la caisse est trop longue**, *The wait at the checkout is too long*. But it can also mean *an expectation*: **Nous essayons toujours de répondre aux attentes de nos clients**, *We always try to meet our customers'' expectations*.', 1),
(52, 2, 'When used as adverbs, the superlatives **le plus**, *the most*, and **le moins**, *the least*, can be placed before the verb as well as after it: **Quelle est l''émission qui vous a le plus fait rire ?** Pre-placement is more literary but nevertheless quite common.', 3),
(52, 3, 'Possessive pronouns (*yours, mine*, etc.) are formed with a definite article (**le, la, les**) and a pronominal word (**mien, tien**, etc.). Like possessive adjectives, they agree in number and gender with the noun(s) they replace, not with the possessor. The pronoun **vôtre** takes a circumflex over the o to distinguish it from the possessive adjective **votre**. **Ceci est votre clé -> C''est la vôtre**.', 5),
(52, 4, 'The adjective **fan**, an abbreviation of **fanatique**, *fanatical*, is used idiomatically to mean wildly enthusiastic. **Je suis fan de foot**, *I''m a football fanatic*. The word can also be used as a noun: **C''est un fan de l''équipe de Bordeaux**, *He''s a fan of the Bordeaux team*. Both adjective and noun are pronounced [fan] (with a short [a]) because they come from the English word.', 6),
(52, 5, 'We have seen **ni** used in a negative construction to mean *nor* (lesson 51 line 18). If the negative verb applies to two things (like *neither... nor*), simply repeat the conjunction instead of using **pas**. **Mes enfants n''aiment ni les fruits ni les légumes**, *My children like neither fruit nor vegetables*. Be careful: unlike in English, the verb must always be negative. **Ni l''un ni l''autre** can often be translated simply as *neither*: **Ni l''un ni l''autre n''est venu**, *Neither came*.', 8),
(52, 6, 'The adjective **faible** means *weak* (see lesson 21) but can be used in a broader sense of lacking. **Elle a une faible chance de réussir**, *She has a slim chance of succeeding*, **Ces légumes sont faibles en calories**, *These vegetables are low in calories*. The corresponding noun is **la / une faiblesse**, *(a) weakness*: **Ma faiblesse en français est un problème dans mon travail**, *My weakness in French is a problem in my job*. By contrast, the expression **avoir un faible pour** means *to have a weakness for* or, idiomatically, *a soft spot for*: **J''ai un faible pour les émissions d''humour**, *I have a soft spot for comedy shows*.', 9),
(52, 7, 'While many verbs can take a reflexive pronoun if the subject and object are identical, others are always (or "essentially") pronominal. For example, **se souvenir (de)** means *to remember* and, in everyday usage, is always pronominal: **Est-ce que tu te souviens de cette émission ?**, *Do you remember that show?* A near-synonym of **se souvenir de** is **se rappeler** (with no partitive article): **Je me rappelle cette émission**, *I remember that show*. (In the non-reflexive form, **rappeler** means *to remind*: **Rappelez-moi votre nom**, *Remind me of your name*.)', 11),
(52, 8, 'The agreement of past participles in pronominal verbs is complex. If the reflexive pronoun (**me, se**, etc.) is the indirect object of the sentence, the participle does not agree with the reflexive pronoun: **Ma femme s''est coupé la main**, *My wife has cut her hand*. But if the pronoun is the direct object, then the participle agrees in gender and number: **Ma femme s''est coupée**, *My wife has cut herself*. In some cases, notably first-group verbs, there is no difference in the pronunciation of the past participle (**coupé** and **coupée** are both pronounced [koopay]). However, this is not the case for the other verb groups, as we shall see.', 13),
(52, 9, 'The concrete noun **une / la cuisine**, *a / the kitchen* (lesson 36 line 6), has an abstract use that means *cooking / cookery* - or even *cuisine*! **J''adore la cuisine basque**, *I love Basque cooking / cuisine*. **Faire la cuisine** means *to cook*, or, more precisely, *to do the cooking*. **Je fais toujours la cuisine pour mes amis**, *I always cook/do the cooking for my friends*.', 12),
(52, 10, 'Used with the past tense and followed by a time period, **il y a** is the equivalent of *ago*: **J''ai vu ce présentateur il y a vingt ans**, *I saw that presenter 20 years ago*. The action described is always complete.', 14),
(52, 11, 'An idiosyncratic use of **manquer** (see lesson 51) is when the verb *to miss* expresses a feeling or regret or sadness. The French sentence structure is the reverse of English: *I miss you* is **Tu me manques** (or **Vous me manquez**), literally "you me are missing". Thus the person (or thing) missed is the subject of the sentence in French but the object in English. Thus if Maïka misses me, I would say **Je manque à Maïka**.', 15);

INSERT INTO contents (course_id, seq, french, english) VALUES
(53, 1, 'Je ferai mes courses comme d''habitude au marché ce vendredi.', 'I will do my shopping as usual at the market this Friday.'),
(53, 2, 'J''achèterai des produits frais, du poisson et de la charcuterie - du pâté et du saucisson.', 'I will buy fresh produce, fish and deli meats -pâté and sausage.'),
(53, 3, 'Je prendrai aussi des fruits: des pêches, des abricots, et des raisins s''il y en a.', 'I''ll also take some fruit: peaches, apricots and grapes if there are any.'),
(53, 4, 'Mais pour les produits du quotidien, j''essaierai de passer une commande en ligne.', 'But for everyday products, I''ll try to place (pass) an order online.'),
(53, 5, 'Dans le rayon épicerie, il me faut des conserves, du sel, du poivre et de la moutarde.', 'In the grocery section, I need canned goods, salt, pepper and mustard.'),
(53, 6, 'J''ai besoin de jus de fruits, de farine, de pâtes, mais aussi de papier toilette et de dentifrice.', 'I need fruit juice, flour, pasta, but also toilet paper and toothpaste.'),
(53, 7, 'Et aussi l''huile d''olive. J''en ajouterai à mon panier si elle est en promotion cette semaine.', 'And olive oil, too. I''ll add some to my basket if it''s on special offer this week.'),
(53, 8, 'Voilà, je valide la commande et je règle mes achats.', 'There, I confirm (validate) the order and I pay for my purchases.'),
(53, 9, 'Finalement, c''est simple comme bonjour ! [...]', 'In the end (finally), it''s as easy as pie (simple as good-day)! [...]'),
(53, 10, 'Bonjour madame, on vient vous livrer les courses que vous avez commandées ce matin.', 'Good morning madam, we [have] come to deliver the shopping that you ordered this morning.'),
(53, 11, 'Où est-ce qu''on les met ? Il y a quatre cartons en tout.', 'Where [shall] we put it? There are four boxes in all.'),
(53, 12, 'Posez-les sur la table contre le frigo dans la cuisine si vous voulez bien.', 'Put them on the table against the fridge in the kitchen if you please.'),
(53, 13, 'C''est à gauche tout au fond du couloir.', 'It''s on the left, right at the end of the corridor.'),
(53, 14, 'Voulez-vous de l''aide pour vider les cartons ?', 'Do you want help to empty the boxes?'),
(53, 15, 'D''abord je vais vérifier que tout est là.', 'First I''m going to check that everything is there.'),
(53, 16, 'Mais ce ne sont pas les articles que j''ai sélectionnés sur le site !', 'But these aren''t the items I selected on the site!'),
(53, 17, 'En plus, vous m''avez livré un paquet de lessive et un bocal de cornichons !', 'What''s more, you''ve delivered a packet of washing powder and a jar of gherkins!'),
(53, 18, 'Je n''ai commandé aucun des deux. Vous allez tout rapporter.', 'I ordered neither of them. You''re going to take everything back.'),
(53, 19, 'Je ne ferai plus jamais mes courses à distance: j''irai au magasin et je parlerai avec un être humain.', 'I''ll never again do my shopping remotely (at distance): I''ll go to the shop and I''ll speak with a human being.'),
(53, 20, 'Ce ne sera pas évident car il y aura beaucoup de monde aujourd''hui.', 'That won''t be easy (obvious) because there will be a lot of people (many-of-world) today.'),

(54, 1, 'Les élections législatives auront lieu dans quelques mois', 'The general (legislative) election will take place in a few months''[time]'),
(54, 2, 'et nous aurons sans doute un nouveau gouvernement.', 'and we shall probably (without doubt) have a new government.'),
(54, 3, 'Les deux partis de centre-gauche feront cause commune contre la droite', 'The two centre-left parties will make common cause against the right'),
(54, 4, 'et présenteront un seul candidat, qui ne sera pas un politique professionnel.', 'and field (present) a single candidate, who will not be a professional politician.'),
(54, 5, 'Ils tiendront un grand meeting à Grenoble ce week-end-ci. Est-ce que vous viendrez ?', 'They will hold a big meeting in Grenoble this weekend. Will you be coming?'),
(54, 6, 'Non, nous ne viendrons pas. Je ne serai pas en France et Romain ne pourra pas se libérer.', 'No, we won''t. I won''t be in France and Romain won''t be able to get away (liberate himself).'),
(54, 7, 'En tout cas, le fameux candidat ne dira rien d''original. C''est toujours la même chanson.', 'In any case, the much-vaunted candidate won''t say anything original. It''s always the same [old] story (song).'),
(54, 8, 'En es-tu sûre? Qui sait ? Il nous surprendra peut-être quand il parlera ce soir.', 'Are you sure of that? Who knows? Perhaps he will surprise us when he speaks (will-speak) tonight?'),
(54, 9, 'J''en suis sûre et certaine, et c''est ça qui me rend triste !', 'I''m [absolutely] sure (and certain), and that''s what makes me sad!'),
(54, 10, 'Alors, contre qui vas-tu t''abstenir cette fois-ci? [...]', 'So, who are you going to abstain against this time? [...]'),
(54, 11, '"Français, Françaises, mes chers compatriotes, rassurez-vous: je ne serai pas long.', '"Frenchmen, French woman, my dear countrymen, rest assured: I won''t be long[-winded].'),
(54, 12, 'Je ne parlerai pas pendant des heures pour ne rien dire.', 'I won''t talk for hours to say nothing.'),
(54, 13, 'Je ne promettrai pas une solution miracle pour résoudre les problèmes du pays.', 'I won''t promise a miracle solution to solve the problems of the country.'),
(54, 14, 'Mais c''est mon devoir de dire la vérité: mon adversaire ne sera ni de droite, ni de gauche:', 'But it''s my duty to tell the truth: my opponent (adversary) won''t be from the right or from the left:'),
(54, 15, 'mon adversaire sera l''argent et la corruption qui l''accompagne.', 'my opponent will be money and the corruption that goes with it.'),
(54, 16, 'Vous n''aurez jamais à douter de mon intégrité, je vous le jure.', 'You will never have to doubt my integrity, I swear [to] you.'),
(54, 17, 'Maintenant, vous savez que vous devrez faire le bon choix, pour vous et votre portefeuille, euh, votre pays.', 'Now, you know you will have to make the right choice, for you and your wallet, er, your country.'),
(54, 18, 'La situation est urgente et vous ne pourrez plus dire: "Ça ne me concerne pas".', 'The situation is urgent and you will no longer be able to say: "It doesn''t concern me."'),
(54, 19, 'Vous n''aurez qu''un choix à faire: voter pour moi.', 'You will have only one choice to make: vote for me.'),
(54, 20, 'Le capitalisme, c''est l''exploitation de l''Homme par l''Homme, mais ma philosophie, c''est le contraire !"', 'Capitalism is the exploitation of man by man, but my philosophy is the opposite!"'),

(55, 1, 'J''ai vu "La Mort atroce" hier. Je te le conseille vraiment.', 'I saw "Dreadful (atrocious) Death" yesterday. I really (you) recommend it.'),
(55, 2, 'Il a battu les records d''audience pour un film d''épouvante.', 'It has broken viewing (audience) records for a horror movie.'),
(55, 3, 'Où l''as-tu vu? En vidéo ?', 'Where did you see it? On video?'),
(55, 4, 'Non, à côté de chez moi il y a un complexe multisalles qui vient d''ouvrir.', 'No, next to my place there''s a multiplex that has just opened.'),
(55, 5, 'La programmation est variée, les salles sont spacieuses, et on y vend de très bonnes glaces !', 'The programming is varied, the theatres (rooms) are spacious, and they sell very good ice cream!'),
(55, 6, 'De quoi parle le film ?', 'What is (Of what speaks) the movie about?'),
(55, 7, 'L''action se passe à Annecy, où j''ai passé toutes mes vacances quand j''étais petite.', 'The action takes place in Annecy, where I spent all my holidays when I was young (small).'),
(55, 8, 'L''une des vedettes est Jeanne Morteau, un monstre sacré du cinéma.', 'One of the stars is Jeanne Morteau, a giant (holy monster) of the movies.'),
(55, 9, 'Elle m''amuse bien avec ses airs de grande dame! Mais quelle actrice !', 'She really amuses me with her fine-lady air (her big lady airs), but what [an] actress!'),
(55, 10, 'C''est l''histoire d''un vieux couple qui, en apparence, s''entend à merveille.', 'It''s the story of an old couple who, apparently, get on marvellously.'),
(55, 11, 'Ils habitent dans un hameau qui se trouve tout près d''un vieil immeuble.', 'They live in a hamlet which is located (finds itself) right near an old [apartment] building.'),
(55, 12, 'Ils pensent que ce bâtiment est abandonné, mais les apparences peuvent tromper ...', 'They think that this building is abandoned, but appearances can be deceptive (deceive)...'),
(55, 13, 'Un jour, la femme est seule à la maison lorsqu''elle entend des bruits étranges dehors.', 'One day, the woman is alone in the house when she hears strange noises outside.'),
(55, 14, 'Elle sort dans la cour, où elle trouve des dizaines d''oiseaux morts par terre.', 'She goes out into the courtyard, where she finds dozens (about-ten) of dead birds on the ground.'),
(55, 15, 'Elle croit d''abord que c''est son chat qui les a tués.', 'She believes at first that it''s her cat which has killed them.'),
(55, 16, 'Mais elle se trompe! Soudain elle voit son mari avec une énorme hache à la main.', 'But she is mistaken! Suddenly she sees her husband with a huge axe in his hand.'),
(55, 17, 'Elle se bat avec lui mais il est beaucoup plus fort et il la bat à coups de bâton.', 'She fights with him but he is much stronger and he hits her with a (of blows of) stick.'),
(55, 18, 'Mais c''est horrible! Qu''est ce qui se passe ensuite ?', 'But that''s horrible! What happens next?'),
(55, 19, 'Je ne sais pas parce que je me suis cachée sous la table jusqu''à la fin.', 'I don''t know because I hid (myself) under the table until the end.'),
(55, 20, 'Néanmoins, je me suis amusée comme une gosse et j''ai adoré le film.', 'Even so (nevertheless), I enjoyed myself like a kid and I loved the movie.'),
(55, 21, 'Du moins, la première moitié...', 'At least, the first half...');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(53, 1, 'This is the first person singular of the future tense of the irregular verb **faire**, *to do/make*: **je ferai**, **tu feras**, **il/elle fera**, **nous ferons**, **vous ferez**, **ils feront**. In most cases, this tense corresponds to the English future with *will*. Note the difference between this tense and the "immediate" future formed with **aller** before the infinitive (in line 4, for example).', 1),
(53, 2, 'The future tense of verbs in the first two groups (ending in **-er** and **-ir**) is formed by adding the endings **-ai**, **-as**, **-a**, **-ons**, **-ez**, **-ont** to the stem. (See lesson 41 note 9). In some cases, the stem changes slightly. For example, with **acheter**, *to buy*, the first e takes a grave accent (**j''achèterai**, etc.) while the y in **essayer** changes to an i (**j''essaierai**, etc.), Neither of these changes makes a noticeable difference to the pronunciation.', 2),
(53, 3, 'Verbs ending in **-re** form their future from the infinitive, but drop the final **-e**. Thus the future tense of **prendre**, *to take*, is **je prendrai**, **tu prendras**, **il/elle prendra**, **nous prendrons**, **vous prendrez**, **ils/elles prendront**.', 3),
(53, 4, '**un rayon** means *a ray* or *a beam* (**Enfin un rayon de soleil!** *At last a ray of sunshine!*). In a shopping context, however, it means a department, section or counter in a store or supermarket. In this case, there is no need for a preposition between **rayon** and the qualifying noun: **le rayon frais**, *the fresh [food] section*.', 5),
(53, 5, '**une promotion** has many meanings, including the cognate *a promotion* (i.e. professional advancement). In stores, it means a special offer. **Les meubles de jardin sont en promotion cette semaine**, *Garden furniture is on special offer this week*. The word is often abbreviated to **en promo**.', 7),
(53, 6, '**Bonjour**, *Good morning*, is used in several idioms, notably **C''est simple comme bonjour**, *It''s as easy as pie*. It can also be found in the idiomatic exclamation **Bonjour les dégâts!** ("Hello the damage"), equivalent to *What a mess!*', 9),
(53, 7, '**tout**, *all, everything* (see line 18) is also used as an adverb of degree, as seen in lesson 51 line 5. **Nous habitons tout près d''ici**, *We live very near here*. As such, it refers not only to physical distance but also to position or intensity: **Ton nom est tout en haut de la liste**, *Your name is right at the top of the list*. In this function, **tout** is invariable.', 13),
(53, 8, '**aucun(e)**, *none, not any* (lesson 46 note 4) can also mean *neither* when followed by **de/des** and a determiner. The accompanying verb is always negative. **Elle n''aime aucune de ces robes**, *She likes neither of these dresses*. (Compare with **ni l''un... ni l''autre**, lesson 52).', 18),
(53, 9, 'Here is the future tense of the irregular verb **aller**, *to go*: **j''irai**, **tu iras**, **il/elle ira**, **nous irons**, **vous irez**, **ils/elles iront**. Note that only the stem is irregular, while the endings are exactly the same as for regular verbs (see note 1).', 19),
(53, 10, 'Another irregular future: **être**, *to be*, becomes **je serai**, **tu seras**, **il/elle sera**, **nous serons**, **vous serez**, **ils/elles seront**. The negative is formed, as usual, with **ne... pas**: **Les commandes ne seront pas livrées demain matin**, *The orders will not be delivered tomorrow morning*.', 20),

(54, 1, 'The abstract noun **le doute** means *doubt*. **Je n''ai pas de doute sur leur réponse**, *I have no doubt about their answer*. The root verb is **douter (de)**. **Il doute de tout**, *He doubts everything*. The phrase **sans doute**, *without a doubt*, can be used to mean *probably*. **Elle a raison sans doute, mais nous devons être certains**, *She''s probably right but we have to be certain*.', 2),
(54, 2, 'The singular noun **la politique**, seen in lesson 49, means *politics*. **La politique est l''art du possible**, *Politics is the art of the possible*. In this context, the noun is never plural. But it can also mean *a policy*: **une politique économique**, *an economic policy*, in which case, it takes a regular plural **-s**: **les politiques économiques**. **Un(e) politique** can also mean a (male or female) politician, although the loan word **un(e) politicien(ne)** is frequently used nowadays. (Remember that **politique** is also an adjective, see lesson 52 line 7).', 4),
(54, 3, 'The noun **un meeting** is used to describe a political gathering or assembly. It is also used in athletics (**un meeting d''athlétisme**). Like most loan words, **meeting** is masculine. (Don''t confuse it with **une réunion**, a business meeting, lesson 38 line 15).', 5),
(54, 4, 'The demonstrative adverb **-ci** (lesson 31 note 3) can be used with time periods to emphasise proximity: **Ce mois-ci**, *This coming month*. It does not have a plural form: **ces jours-ci**, *[in] the coming days*.', 5),
(54, 5, 'The adjective **célèbre** (the origin of *celebrity* and *celebrated*, lesson 52 line 11) means *famous* or *well-known*. But **fameux** has a much broader meaning, often relating to quality. **Son pâté est fameux!**, *His (or Her)! pâté is fantastic!* The word can also be used to describe something that has been widely discussed: **C''est ça, ton fameux plan ? C''est nul!** *Is that the plan that you''ve been talking about? It''s rubbish!*', 7),
(54, 6, 'In a subordinate clause beginning with a time expression, such as **quand**, the verb is in the future tense if the verb in the main clause is also in the future. This contrasts with English, which uses the present. **Nous serons tous là quand il arrivera**, *We will all be there when he arrives*.', 8),
(54, 7, 'Remember that adjectives always agree in gender with the person they refer to, but those ending in **-e** (like **triste**, *sad*) in both masculine and feminine agree only in the plural, **des choses tristes**, *sad things* (See lesson 14).', 9),
(54, 8, '**devoir** is a verb, *must* (lesson 17 note 5), but also a masculine noun meaning *duty*: **C''est mon devoir de vous le dire**, *It''s my duty to tell you*. In a school context, it is used in the plural (**les devoirs**) to mean *homework* (because the student is obliged to do the work).', 14),
(54, 9, '**l''homme** is used in the general sense to mean *mankind*. For that reason, it is often written with an initial capital: **Le Musée de l''Homme à Paris est fermé le mardi**, *The Museum of Mankind in Paris is closed Tuesdays*. A concerted effort is underway in France to move towards more gender-neutral language, especially in official contexts. So the expression **les droits de l''homme** (or **l''Homme**), "the rights of man" is making way for **les droits humains**, the back translation of human rights. (The Canadian francophone community has long used the term **les droits de la personne**.)', 20),

(55, 1, 'The feminine noun **épouvante** means *terror, dread*. It is the root of a common adjective, **épouvantable**, which means *dreadful* or *appalling*. **Quel temps épouvantable!** *What dreadful weather!*. In everyday language, the term **un film d''épouvante** is often replaced by the back translation **un film d''horreur**.', 2),
(55, 2, '**La glace** means *ice*, as in **l''ère de glace**, *the ice age*. In everyday language, however, **une glace** means *an ice cream*. French and English have both experienced a similar elision: the "proper" French term is **une crème glacée**, equivalent to *an iced cream*, the correct term for an ice cream.', 5),
(55, 3, 'We know (lesson 48 note 10) that **passer** means *to pass* and the reflexive form **se passer** means *to happen*. To remember the difference, try memorising the sentence: **Le film se passe à Paris, où je passe mes vacances**, *The film takes place in Paris, where I spend my holidays*. This lesson features other examples of verbs that have a slightly different meaning in the indicative and pronominal forms.', 7),
(55, 4, '**un monstre sacré** ("a holy monster") is an admirative term similar to the English epithet *a giant* or *a legendary figure*. **Gérard Grandieu est un monstre sacré du cinéma français**, *Gérard Grandieu is a giant of French cinema*. The expression applies to both men and women. However, the noun **un monstre** is used pejoratively, as in English: **C''est un monstre horrible qui fait peur aux enfants**, *He''s a dreadful monster who scares children*.', 8),
(55, 5, '**amuser** means *to amuse* (someone): **Il m''amuse avec ses histoires drôles**, *He amuses me with his funny stories*. The pronominal form, seen in lesson 47 line 2, generally means *to enjoy* or *to have fun*. **Il joue mal de la guitare mais il s''amuse**, *He plays the guitar badly but he enjoys himself*.', 9),
(55, 6, '**entendre** means *to hear* (and we know the past participle **entendu**, lesson 38 note 8, meaning, *I see* or *I understand*). And, as a simple reflexive, **s''entendre** means *to hear oneself*. **Faites moins de bruit, je ne m''entends pas parler au téléphone**, *Make less noise, I can''t hear myself speaking on the phone*. As an idiomatic pronominal verb, **s''entendre** means *to reach an agreement with* or, more commonly, *to get on well with* someone. **Je m''entends très bien avec le frère de Jacques**, *I get on well with Jacques'' brother*.', 10),
(55, 7, 'See lesson 51 note 8.', 11),
(55, 8, '**se tromper** (lesson 50 line 5), *to make a mistake*, is the pronominal form of **tromper**, *to deceive or mislead*: **Le vendeur m''a trompé sur le prix des appels téléphoniques**, *The salesman misled me about the price of phone calls*. The transitive verb can also mean *to be unfaithful to, cheat on*. **Si une femme trompe son mari, c''est souvent parce que le mari trompe sa femme**: *If a wife is unfaithful to her husband, it''s often because the husband is cheating on his wife*.', 12),
(55, 9, 'We have already seen **un coup** in several expressions (**un coup d''œil**, **un coup de main**, lesson 32, for example). Here we have the original meaning, *a blow*, *a knock*, etc. **J''ai pris un coup sur la tête**, *I banged my head*. In these contexts, English is more flexible than French. For instance, **donner un coup de poing/de pied** ("to give a blow of the fist/foot") is *to punch/kick*. The expression **à coups de** describes the thing delivering the blow: **Elle le battait à coups de brosse**, *She was hitting him with a brush*.', 17),
(55, 10, '**un(e) gosse**, a common informal word for a child, is the equivalent of *a kid*: **Ils vont en vacances sans les gosses ce mois-ci**, *They''re going on holiday without the kids this month*. Like **monstre sacré** (note 4), the noun is masculine but can apply to both sexes. Two common related idioms are **un sale gosse** (*a brat*) and **un beau gosse**, *a good-looker*. (Be careful: in Canadian French, **gosse** is a testicular slang word!)', 20);

INSERT INTO contents (course_id, seq, french, english) VALUES
(57, 1, 'Comment ça se fait que vous parlez tous les deux le breton ?', 'How come (how that does-itself) you both (all the two) speak Breton?'),
(57, 2, 'L''explication est simple. Nous avons vécu à Vannes pendant dix ans quand nous étions plus jeunes.', 'The explanation is simple. We lived in Vannes for ten years when we were younger.'),
(57, 3, 'J''enseignais au collège et mon mari travaillait dans une entreprise de construction navale.', 'I was teaching in middle school and my husband was working in a ship-building (naval construction) company.'),
(57, 4, 'Beaucoup de gens autour de nous parlaient cette langue, ce qui nous a motivé à l''apprendre.', 'Many people around us spoke the language, which motivated us to learn it.'),
(57, 5, 'Est-ce que c''était difficile à maîtriser ?', 'Was it hard to master?'),
(57, 6, 'Nous avions beaucoup de chance parce que nous habitions un quartier de la ville', 'We were very lucky because we were living in a part of the town'),
(57, 7, 'où les commerçants avaient presque tous le breton comme première langue,', 'where almost all the shopkeepers spoke (had) Breton as [their] first language,'),
(57, 8, 'donc nous étions obligés de le parler, rien que pour acheter du pain !', 'so we were obliged to speak it, if only (nothing that) to buy bread!'),
(57, 9, 'A propos, saviez-vous que le verbe "baragouiner" était d''origine bretonne ?', 'By the way, did you know that the verb baragouiner [to talk gibberish] was of Breton origin?'),
(57, 10, 'C''est vrai? Je ne le savais pas. Vous m''apprenez quelque chose !', 'Is that true? I didn''t know. That''s news to me (you teach-me something)!'),
(57, 11, 'Autrefois, beaucoup de Bretons montaient à Paris pour trouver du travail.', 'In the past, many Bretons came up to Paris to find work.'),
(57, 12, 'Le voyage était très long et ils arrivaient souvent affamés.', 'The journey was very long and they were often famished when they arrived.'),
(57, 13, 'Ils entraient dans le premier café qu''ils trouvaient', 'They went into the first café that they came across (found)'),
(57, 14, 'et commandaient du pain et du vin. Mais ils ne parlaient que le breton,', 'and ordered bread and wine. But they only spoke Breton,'),
(57, 15, 'donc ils demandaient du bara et du guin - et personne ne les comprenait.', 'so they asked for "bara" and "guin"-and no-one understood them.'),
(57, 16, '"Que disent ces Bretons ? On n''y comprend rien", disaient les Parisiens.', '"What are these Bretons saying? We can''t make head nor tail of it," the Parisians used to say.'),
(57, 17, '"Ils baragouinent !". Et voilà d''où vient ce mot.', '"They''re talking gibberish!" And that''s where the word comes from.'),
(57, 18, 'Elle est absolument fascinante, ton histoire. Je ne la connaissais pas.', 'Your story is absolutely fascinating. I didn''t know it.'),
(57, 19, 'Pourtant j''allais souvent en Bretagne avec mes parents quand j''étais petit.', 'And yet I often used to go to Brittany with my parents when I was little.'),
(57, 20, 'J''aimais bien la région, mais il pleuvait tout le temps et on ne sortait presque jamais de la maison.', 'I really liked the region but it rained all the time and we almost never left the house.'),
(57, 21, 'Il pleuvait sans doute, mais au moins en été la pluie bretonne est plus chaude.', 'It was certainly raining, but at least the Breton rain is warmer in summer.'),

(58, 1, 'Allons à Auxerre ce week-end, puisque mardi est férié.', 'Let''s go to Auxerre this weekend, since Tuesday is a public holiday.'),
(58, 2, 'Nous pourrons faire le pont du premier novembre et passer quatre jours complets.', 'We can take the long weekend (make the bridge) of 1st November and spend four full days.'),
(58, 3, 'Ça sera chouette, non? Un peu de ciel bleu, ça nous changera les idées.', 'It will be great, won''t it? A bit of blue sky will give us something different to think about (change us the ideas).'),
(58, 4, 'Tu n''as pas l''air enthousiaste. Qu''est-ce qu''il y a?', 'You don''t seem very keen. What''s up?'),
(58, 5, 'D''abord, qu''est-ce qu''il y a à voir à Auxerre ? C''est une ville comme une autre.', 'First, what is there to see in Auxerre? It''s a town like [any] other.'),
(58, 6, 'Mais il y a plein de choses à visiter: regarde dans le guide de voyage:', 'But there a loads of things to visit: look in this travel guide:'),
(58, 7, '"La vieille ville, la Tour de l''Horloge, l''abbaye, les beaux hôtels particuliers,', '"The old town, the Clock Tower, the abbey, handsome private mansions,'),
(58, 8, 'et des maisons à pans de bois sont parmi les sites incontournables à apprécier".', 'and half-timbered (sections of wood) houses are among the key things (unescapables) to enjoy."'),
(58, 9, 'Ça vaut la peine, je t''assure. Tu ne le regretteras pas.', 'It''s worth it, I assure you. You won''t regret it.'),
(58, 10, 'À vrai dire, j''ai la flemme de quitter la maison, surtout pour un long week-end.', 'To tell the truth (to true say), I can''t be bothered to leave the house, especially for a long weekend.'),
(58, 11, 'D''abord, il faudra partir au petit matin car la plupart des Parisiens seront sur la route, et il y aura un monde fou.', 'First, we''ll have to leave in the early hours (little morning) because most (of the) Parisians will be on the road and there''ll be loads of people (mad world).'),
(58, 12, 'La dernière fois que je suis allé en Bourgogne, j''ai mis une demi-journée à faire cinquante kilomètres !', 'The last time that I went to Burgundy, I spent (put) half a day doing fifty kilometres!'),
(58, 13, 'Je suis resté coincé dans les embouteillages pendant quatre heures et demie, et ce n''était pourtant pas un jour férié.', 'I was (stayed) stuck in traffic jams for four-and-a-half hours and yet it wasn''t a public holiday.'),
(58, 14, 'Pire, il faisait un froid de canard et il tombait des cordes.', 'Worse, it was freezing and it was pouring with rain (fell ropes).'),
(58, 15, 'Selon la météo, il fera beau, chaud et ensoleillé toute la semaine.', 'According to the weather forecast, it will be fine, hot and sunny all week.'),
(58, 16, 'Peut-être bien, mais les hôtels seront complets ou ruineux,', 'Maybe, but the hotels will be [either] full or ruinous[ly expensive],'),
(58, 17, 'et je n''ai pas les moyens de jeter l''argent par les fenêtres.', 'and I can''t afford to throw money away (by the window).'),
(58, 18, 'J''abandonne! Tu es têtu comme une mule.', 'I give up (abandon)! You are [as] stubborn as a mule.'),

(59, 1, 'Quand mon père était jeune, les moyens de communication que nous avons aujourd''hui n''existaient pas.', 'When my father was young, the means of communication that we have today did not exist.'),
(59, 2, 'S''il voulait contacter un parent ou un ami, il devait écrire une lettre ou, en cas d''urgence, envoyer un télégramme...', 'If he wanted to contact a relative (parent) or a friend, he had to write a letter or, in case of emergency, send a telegram...'),
(59, 3, 'Un quoi? Je pensais qu''un télégramme était un journal breton!', 'A what? I thought a telegram was a Breton newspaper!'),
(59, 4, 'Non, imbécile, les télégrammes permettaient ... Laisse tomber, tu n''étais même pas né.', 'No, idiot, telegrams allowed... Drop it, you weren''t even born.'),
(59, 5, 'Je disais donc que papa ne pouvait jamais s''attendre à une réponse instantanée.', 'So I was saying that dad could never expect (wait himself) an instant answer.'),
(59, 6, 'Il ne pouvait pas non plus obtenir une information immédiatement.', 'Neither could he get (obtain) information immediately.'),
(59, 7, 'Comme c''est affreux! Il n''avait pas le téléphone? Ça existait alors, non ?', 'How (it is) awful! He didn''t have a phone? It existed back then, didn''t it?'),
(59, 8, 'Bien sûr, mais les appels coûtaient très cher donc on ne téléphonait que rarement.', 'Of course, but calls were (cost) very expensive and people telephoned only rarely.'),
(59, 9, 'Si j''ai bien compris, les forfaits illimités n''existaient pas encore ?', 'If I have understood correctly (well), unlimited phone plans didn''t yet exist?'),
(59, 10, 'C''est ça. Et on utilisait des pigeons voyageurs pour communiquer. Non, je plaisante.', 'That''s right. And we used homing (travelling) pigeons to communicate. No, I''m joking.'),
(59, 11, 'À cette époque, papa jouait au Tiercé toutes les semaines.', 'At that time, dad used to play the Tiercé every week.'),
(59, 12, 'Comme lui et maman vivaient loin du village voisin, il prenait son vélo pour aller au PMU.', 'As he and mum lived far from the neighbouring village, he would take his bike to go to the betting office.'),
(59, 13, 'Il ne gagnait jamais mais ça l''amusait de jouer et il aimait bien se balader à la campagne.', 'He never won but he enjoyed (amused himself) playing and he liked riding around the country.'),
(59, 14, 'Je suis sûr que tes parents espéraient toucher le gros lot.', 'I''m sure that your parents were hoping to get (touch) the jackpot.'),
(59, 15, 'C''est possible mais j''en doute. Malheureusement, mon père choisissait ses chevaux au hasard.', 'It''s possible but I doubt it. Unfortunately (unhappily), dad used to choose horses at random.'),
(59, 16, 'Il lançait des dés ou jouait à pile ou face, c''est pourquoi il perdait toujours.', 'He would throw dice or flip a coin (play at tails or heads), which is why he always lost.'),
(59, 17, 'Enfin, presque toujours. Une nuit, pendant qu''il dormait, il a fait un rêve...', 'Well, almost always. One night, while he was sleeping, he had (made) a dream...'),
(59, 18, 'Le lendemain, il ne se souvenait pas exactement du nom du gagnant mais pensait qu''il s''appelait "Fortune".', 'The next day, he didn''t remember exactly the name of the winner but he thought it was called "Fortune."'),
(59, 19, 'Mais ce jour-là il pleuvait tellement fort que papa n''a pas pu aller au village.', 'But that day, it was raining so hard that dad was unable to go to the village.'),
(59, 20, 'Et heureusement, car il n''y avait pas de "Fortune".', 'And fortunately, because there was no "Fortune."'),
(59, 21, 'C''est la semaine suivante que "Bonne Fortune" a remporté la course et papa a touché... une petite fortune !', 'It''s the following week that "Good Fortune" took the race and dad got (touched)...a small fortune.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(57, 1, '**Comment ça se fait ?** ("How that does itself") is an idiomatic way of asking a question, a little like *How come...* **Il n''est pas parti en vacances cette année - Comment ça se fait ?** *He didn''t go on holiday this year? How come?* The expression can also be used in a full sentence: **Comment ça se fait que le train est en retard?** *How come the train is late?* In this case, however, it is often necessary to put the main verb into the subjunctive, which we will learn later on.', 1),
(57, 2, 'French does not have a word for *both*, relying on various constructions according to the grammatical function. As an adjective, you can use **les/des/aux deux**. **J''ai mal aux deux genoux**, *Both my knees hurt*. As a pronoun, use **tous les deux**. **Ils sont bretons, tous les deux**, *They''re both Breton*.', 1),
(57, 3, 'Here is the imperfect tense, glimpsed in lesson 55 line 7. It is used to describe situations or actions in the past, without specifying when they began or ended. The imperfect form of the irregular verb **être** is **j''étais, tu étais, il/elle/on était, nous étions, vous étiez, ils/elles étaient**. The nearest equivalent in English is *was / were*.', 2),
(57, 4, 'The imperfect tense of all verbs other than **être** (see note 3) is formed by dropping the **-ons** ending from the **nous** form of the present and adding the following endings: **enseignons** -> **j''enseignais, tu enseignais, il/elle enseignait, nous enseignions, vous enseigniez, ils/elles enseignaient**. Depending on the context, the translation uses *was teaching* or *used to teach*. In this same sentence, **travaillait** is the third-person singular imperfect of **travailler**.', 3),
(57, 5, '**un commerçant** comes from the noun **le commerce**, *trade* (Here is another example of Latin/Anglo-Saxon variations: *trade* concerns the exchange of goods and some services, whereas *commerce* encompasses a broader range of ancillary activities). Depending on the context, **un(e) commerçant(e)** can be a trader but also a shopkeeper or merchant.', 7),
(57, 6, 'This is the imperfect of **savoir**: **savons** -> **je savais, tu savais, il/elle/on savait, nous savions, vous saviez, ils/elles savaient**. (See also note 10.)', 9),
(57, 7, '**baragouiner** is a familiar verb meaning *to talk gibberish* or less insultingly, *to speak a language badly, mumble a few words*: **Il baragouinait le russe**, *He was speaking bad Russian*.', 9),
(57, 8, 'We know that **apprendre** means *to learn* and **enseigner** *to teach*. However, when used with a direct object and an indirect object in the same phrase, **apprendre** means *to teach* (something to someone). So, **J''apprends le français**, *I''m learning French* but **Je leur apprends le français**, *I''m teaching them French*. By contrast, **enseigner** means only *to teach*: **Je leur enseigne le français**. The idiomatic expression **Vous m''apprenez/Tu m''apprends quelque chose** is the equivalent of *That''s news to me* (or, more simply, *I didn''t know that*).', 10),
(57, 9, 'We know that adjectives of nationality do not take an initial capital, whereas nouns do (lesson 20 note 3). Logically, the lower-case rule applies to adjectives derived from regions, towns, etc., as well as to languages. **C''est un Normand qui parle mal l''anglais**, *He''s a Norman who speaks bad English*. Be careful not to confuse nouns and adjectives of nationality: **Ce sont des Bretons** but **Ils sont bretons**. (Alternatively, **Ils sont d''origine bretonne**, *They''re of Breton origin*.)', 9),
(57, 10, 'We know that the adverbial pronoun **y** refers back to a previously mentioned indirect object, usually a thing or place, generally introduced by **à** (see lesson 35 section 3.1.) Thus, in the idiomatic phrase **on n''y comprend rien**, **y** replaces that indirect object **le film**: **À la fin du film, on n''y comprend rien** (i.e. au film), *By the end of the movie, nobody understands anything*. If the indirect object comes after the verb, however, **y** is not used, and **rien** returns to its usual place, directly after the verb. **On n''a rien compris au film**.', 16),
(57, 11, 'To remind yourself of how to use **connaître** (line 18) and **savoir** (line 10), look back at lesson 35 section 4.', 18),

(58, 1, 'Although **une chouette** means *an owl*, the word is often used as a familiar adjective meaning *great, cool, nice*, etc. **Il est vraiment chouette, ton nouveau sac**, *Your new handbag is really nice*. (And, just like *nice*, the meaning is vague!) **Chouette** can also be used as an exclamation, sometimes followed by **alors**. **On ira à Auxerre demain. - Chouette alors!** *We''ll go to Auxerre tomorrow - Great!*', 3),
(58, 2, 'The idiom **Qu''est-ce qu''il y a?** means *What''s wrong?* or *What''s up?* Unlike **Qu''est-ce qui ne va pas ?** (lesson 24 line 1), where something is visibly wrong. **Qu''est-ce qu''il y a?** is often a more general way of making an enquiry: **Qu''est-ce qu''il y a? Je veux vous parler**, *What is it? - I want to talk to you*.', 4),
(58, 3, 'Here are two false friends. The adjective **particulier**, *particular, distinctive*, can also mean *private* when used in the compound noun **un hôtel particulier**, *a private mansion*. (In this context, **un hôtel** takes no guests!) The noun **un particulier** means *a private individual*, as opposed to a company. Website contact pages often ask the question: **Êtes-vous un particulier ou une entreprise?** *Are you an individual or a business?*', 7),
(58, 4, 'Here is another use of the third person of **valoir** (lesson 44 line 18): the impersonal expression **Ça vaut...** followed by a noun means *It''s worth...*. **Ça vaut la peine**, *It''s worth the trouble* (see lesson 46 note 8). Some tourist guides rate important monuments, sites and even restaurants simply as **Vaut le voyage**, *Worth the trip*.', 9),
(58, 5, 'The feminine noun **la flemme** is derived from the medical term **le flegme**, *phlegm*, and conveys the idea of laziness; it is used almost exclusively in the expression **avoir la flemme**: **J''ai la flemme de faire le lit**, *I can''t be bothered to make the bed*.', 10),
(58, 6, 'We know that **le monde**, *the world*, is a synonym for people (**tout le monde, beaucoup de monde**). The idiomatic expression **Il y a un monde fou** ("a mad world") means *It''s really crowded / There are loads of people*, etc. **Il y a un monde fou dans les magasins à Noël**, *The shops are really crowded at Christmas*.', 11),
(58, 7, 'The adverb **pourtant**, seen in the previous lesson, is a useful way of expressing a contradiction, like *yet* or *however*. It can be used directly after a verb: **Il reste pourtant beaucoup de choses à faire**, *But there''s still a lot to do*, or at the beginning of a sentence, usually with **Et...**, as a rejoinder: **Tu es en retard. Et pourtant, je me suis levé tôt**, *You''re late. And yet I got up early*. Note where the adverb is positioned in comparison to English.', 13),
(58, 8, '**un canard** means *a duck*: **Suzanne vend des poulets et des canards au marché depuis dix ans**, *Suzanne has been selling chickens and ducks at the market for ten years*. Since ducks are apparently easier to hunt in the winter, they have become synonymous with bitter cold: **Il fait un froid de canard dehors**, *It''s freezing outside*.', 14),
(58, 9, '**une corde** means *a rope* or, on a musical instrument, *a string*. Since streams of heavy rain can resemble thick ropes, the expression **tomber (or pleuvoir) des cordes** means *to pour with rain*. (The English noun *a cord* is generally translated by **un cordon**.)', 14),
(58, 10, '**un bulletin météorologique** is the official term for a weather forecast. For simplicity, it is usually abbreviated to **la météo**, another example of the tendency to shorten longer phrases in the everyday language (lesson 17 note 7): **As-tu entendu la météo pour aujourd''hui ?** *Have you heard today''s weather forecast?* And **la météo** can also mean simply *the weather*: **Si la météo est mauvaise, nous ne sortirons pas le bateau**, *If the weather is bad, we won''t get the boat out*.', 15),

(59, 1, 'We know that **les moyens** can mean *financial resources* (lesson 37 note 6) but it is also the word for *means*, i.e. a method for achieving something. However, while the English word takes an s, even in the singular, **un moyen/les moyens** depends on the context: **J''ai trouvé un moyen de le contacter**, *I''ve found a means of contacting him*. Contrast that with **Il y a deux moyens de payer: par téléphone ou par carte**, *There are two means of payment: by phone or by card*.', 1),
(59, 2, '**un parent** means *a parent* but also *a relative* (cousin, niece, etc.). So **mes parents et amis** can mean *my parents* OR *my relatives and friends*. The word is also used in the expression **le parent pauvre**: **Le changement climatique est le parent pauvre des politiques de ce gouvernement**, *Climate change is the poor relative of this government''s policies*. Always check the context!', 2),
(59, 3, 'The feminine noun **urgence** means *urgency*, and, in some cases, *rush*: **Il n''y a pas d''urgence, ça peut attendre**, *There''s no rush; it can wait*. With the partitive **d''**, it means *emergency*: **La mairie a pris des mesures d''urgence**, *The town hall has taken emergency measures*. And the emergency department of a hospital, **le service des urgences**, is often referred to simply as **les urgences**.', 2),
(59, 4, 'The compound verb **laisser tomber** ("to allow to fall") means *to drop*: **Attention, il va laisser tomber le sac par terre !**, *Watch out, he''s going to drop the bag on the floor!* Idiomatically, the expression can mean - as in English - *to abandon*: **Il a laissé tomber ses études de médicine**, *He dropped his medical studies*. (Note the construction; we''ll meet it again shortly.) As an interjection, **Laisse(z) tomber !** is equivalent to *Forget it!*, expressing irritation or boredom: **Cet exercice est trop difficile. - Laissez tomber**, *This exercise is too hard. Forget it.* In this context, there is no need for a direct object.', 4),
(59, 5, '**alors**, seen several times with the meaning *so* or *then*, literally means *at the time, back then* (from **lors**, which we will see later): **Je l''ai connue à la fac. Elle était alors étudiante**, *I knew her at uni. Back then, she was a student*. A shorter, more elegant way of saying **à cette époque** (line 12), **alors** is never used at the beginning of a sentence in this context.', 7),
(59, 6, '**un forfait** basically means *an all-in financial package* or *a fixed sum*. It is widely used in two contexts: travel (for example, **un forfait avion-hôtel**, *a flight and hotel package*) and telephony, where the basic meaning is *a phone plan*: **J''ai dépassé mon forfait**, *I''ve exceeded my plan limit*.', 9),
(59, 7, '**papa** and the feminine equivalent **maman** are the equivalents of *mum(my)* and *dad(dy)*. **Papa et maman sont mariés depuis plus de trente ans**, *Dad and mum have been married for more than 30 years*. In everyday usage, **une maman** is more common that **une mère**.', 11),
(59, 8, '**un voisin** means *a neighbour* (we saw the feminine form in lesson 36) but the word can also be an adjective, meaning *neighbouring, nearby*, etc. **Ils habitent dans la rue voisine**, *They live in the next street*. By extension, **le voisinage** means *the neighbourhood*.', 12),
(59, 9, 'The little-used English word *velocipede*, a forerunner of the bicycle, comes from the French **un vélocipède**, which passed long ago into everyday language as **un vélo**, *a bike*. The "technical" term is **une bicyclette**. Such is the longstanding popularity of cycling in France that the affectionate term for the machine is **la petite reine** ("little queen").', 12),
(59, 10, '**un hasard** (lesson 22 line 1) is another faux-ami, meaning *chance* or *luck*. **Je l''ai rencontré par hasard dans la rue hier**, *I met him by chance in the street yesterday*. The expression **au hasard** means *randomly* (or *haphazardly*). **Il répondait toujours au hasard à mes questions**, *He always used to answer my questions at random*. (A *hazard* is translated as **un risque** or **un danger**.)', 15);

INSERT INTO contents (course_id, seq, french, english) VALUES
(60, 1, 'L''incendie a commencé peu après la fermeture du bar, aux environs de minuit.', 'The fire began shortly after the (closing of) bar closed, around midnight.'),
(60, 2, 'Que faisiez-vous à ce moment-là ? Étiez-vous dans les environs ?', 'What were you doing at that time? Were you in the vicinity?'),
(60, 3, 'Non, je n''y étais plus. Je rentrais chez moi à pied et je n''ai rien vu du tout.', 'No, I was no longer there. I was walking home and I didn''t see anything at all.'),
(60, 4, 'J''ai quelque chose à vous dire, monsieur le brigadier...', 'I have something to tell you, officer (mister the brigadier)...'),
(60, 5, 'Un peu de patience, madame, s''il vous plaît. Et vous monsieur? Qu''avez-vous vu ?', 'A little patience, madam, please. And you, sir? What did you see?'),
(60, 6, 'Je sortais de la bouche du métro lorsque j''ai aperçu un grand nuage de fumée.', 'I was coming out of the metro entrance (mouth) when I noticed a big cloud of smoke.'),
(60, 7, 'Je pensais d''abord que c''était du brouillard car le temps était maussade et il bruinait depuis peu.', 'I thought at first that it was fog because the weather was gloomy and it had been drizzling for a short while.'),
(60, 8, 'Mais je me suis rendu compte que l''immeuble à l''angle du l''avenue brûlait.', 'But I realised that the building on the corner of the avenue was burning.'),
(60, 9, 'J''ai pris mon téléphone pour appeler les secours mais quelqu''un l''avait déjà fait.', 'I took my phone to call the emergency services but someone had already done it.'),
(60, 10, 'Les pompiers ont mis peu de temps à venir - moins de trois minutes, pas plus.', 'The firefighters came quickly (put little of time to come) -less than three minutes, no more.'),
(60, 11, 'En tout cas, ils sont arrivés juste à temps car le toit était complétement en flammes.', 'In any case, they arrived just in time because the roof was completely in flames.'),
(60, 12, 'Mais laissez-moi parler! Saviez-vous que le voisinage était de plus en plus dangereux ?', '(But) Let me speak! Did you know that the neighbourhood was increasingly dangerous?'),
(60, 13, 'Peu importe. Continuez, monsieur. Combien y avait-il de camions, plus ou moins ?', 'Never mind. Go on sir. How many trucks were there, more or less?'),
(60, 14, 'Au début il y en avait peu - trois ou quatre je crois, pas plus -,', 'At the beginning, there weren''t many (were few) - three or four I believe, no more-,'),
(60, 15, 'mais d''autres sont arrivés peu de temps après. J''en ai vu plus d''une dizaine, environ.', 'but others arrived shortly (a little time) afterwards. I saw around ten of them.'),
(60, 16, 'Ils sont arrivés pendant que l''immeuble continuait à brûler de plus en plus fort.', 'They arrived while the building continued to burn increasingly fiercely.'),
(60, 17, 'Les équipages ont réalisé un travail formidable.', 'The crews did an amazing job.'),
(60, 18, 'S''il vous plaît, j''attends depuis longtemps. Écoutez-moi et, après, je ne dirai plus rien.', 'If you please, I''ve been waiting for a long time. Listen to me and, afterwards, I won''t say anything else.'),
(60, 19, 'Encore vous ! Mais que voulez-vous ?', 'You again (still you)! But what do you want?'),
(60, 20, 'Je voulais vous prévenir que pendant que vous parliez avec ces gens quelqu''un a volé votre voiture, celle qui était garée là-bas.', 'I wanted to warn you that while you were talking to these people someone stole your car, the one that was parked over there.'),
(60, 21, 'Et quand aviez-vous l''intention de m''en parler ? Plus tard, peut-être ?', 'And when did you intend (had the intention) to talk to me about it? Later, maybe?'),

(61, 1, 'Mon invitée est la photojournaliste Isabelle Rossi, pour son nouveau livre "L''Histoire en images".', 'My guest is the photojournalist Isabelle Rossi, for her new book "History in Pictures."'),
(61, 2, 'Bonjour, Isabelle. Pouvez-vous raconter à nos auditeurs comment vous avez choisi votre carrière ?', 'Hello, Isabelle. Can you tell our listeners how you chose your career?'),
(61, 3, 'Avec plaisir. Je suis née il y a soixante-dix ans à Ajaccio dans une famille plutôt modeste.', 'With pleasure. I was born seventy years ago in Ajaccio to a fairly modest family.'),
(61, 4, 'Je savais très jeune que je voulais devenir peintre et que, pour ça, il fallait quitter la Corse,', 'I knew [when] I was very young that I wanted to be a painter and, for that, it was necessary to leave Corsica,'),
(61, 5, 'm''installer en Métropole, et fréquenter des gens avec les mêmes intérêts que les miens.', 'settle (install myself) on the mainland, and keep company with (frequent) people with the same interests as mine.'),
(61, 6, 'C''était dur au début car j''étais plutôt timide et je ne connaissais pas grand monde.', 'It was tough at the beginning because I was quite shy and I didn''t know a lot of (great) people.'),
(61, 7, 'Mais petit à petit je me suis fait des amis et aussi j''ai fait la connaissance d''autres gens comme moi.', 'But little by little I made (myself) friends and also made the acquaintance of other people like me.'),
(61, 8, 'Mais vous avez laissé tomber assez vite la peinture. Pourquoi cette décision ?', 'But you abandoned painting quite quickly. Why [make] that decision?'),
(61, 9, 'Je me suis rendu compte que, en définitive, je n''étais pas si douée que ça.', 'I realised that, in fact, I wasn''t as gifted as that.'),
(61, 10, 'En revanche, j''avais un don pour la photographie - pas des paysages ou la mode -', 'By contrast (in revenge), I had a gift for photography -not landscapes or fashion-'),
(61, 11, 'mais plutôt pour, à la fois des portraits et des scènes de la vie ordinaire.', 'but both (at the [same] time,) portraits and scenes from ordinary life.'),
(61, 12, 'Cependant il y avait peu de femmes photographes professionnelles à ce moment-là;', 'However, there were few professional women photographers at that time'),
(61, 13, 'et, pour réussir, j''ai dû surmonter des obstacles et apprendre à ne jamais baisser les bras.', 'and, to succeed, I had to overcome obstacles and learn to never give up (lower the arms).'),
(61, 14, 'J''ai enfin trouvé ma voie et mon bonheur - en devenant photographe de rue.', 'I finally found my way [in life] -and my happiness- by becoming a street photographer.'),
(61, 15, 'J''adorais flâner à travers la ville, le matin de bonne heure, quand la journée commençait,', 'I loved wandering through the city, early (of good time) in the morning, when the day was beginning'),
(61, 16, 'et prendre en photo les gens qui s''occupaient de leurs affaires et vivaient leur vie.', 'and photographing (taking in photo) people who were going about their business and living their lives.'),
(61, 17, 'Il fallait leur demander la permission d''être photographiés mais la plupart d''entre eux disaient oui.', 'It was necessary to ask their permission to be photographed, but most of (among) them said yes.'),
(61, 18, 'Certains refusaient, souvent par timidité, et je savais que ça ne valait pas la peine d''insister.', 'Some would refuse, often out of shyness, and I knew that it wasn''t worth insisting.'),
(61, 19, 'Mais vous avez réussi brillamment et vous êtes devenue très vite célèbre.', 'But you succeeded brilliantly and you quickly became very famous.'),
(61, 20, 'Vous savez, la célébrité ne me dit pas grand-chose. En fait ça m''énerve,', 'You know, fame (celebrity) doesn''t mean (says) much (great-thing) to me. In fact, it annoys me'),
(61, 21, 'car une belle photo vaut mieux qu''un long discours ou le succès médiatique.', 'because a beautiful photo is worth more than a long speech or media success.'),

(62, 1, 'On m''a dit "Apprends à coder et les entreprises t''accueilleront les bras ouverts !".', 'I was told "Learn to code and companies will welcome you with open arms."'),
(62, 2, '"Elle font les yeux doux aux informaticiens qui ont les dents longues"', '"They make (sweet) eyes at ambitious computer scientists (who have long teeth).'),
(62, 3, 'J''ai eu un coup de cœur pour le métier de programmateur - eh oui, ça arrive -', 'I was taken with the job of programmer -oh yes, it happens-'),
(62, 4, 'et j''ai fait la sourde oreille à ceux qui me déconseillaient de poursuivre.', 'and I turned a deaf ear to those who advised me against ("dis-advised") from continuing (pursuing).'),
(62, 5, 'J''ai commencé une formation mais j''ai vite appris que ce n''était pas si évident que ça.', 'I started a training [session] but I quickly learned that it wasn''t as easy as that.'),
(62, 6, 'Si certains concepts sont simples, d''autres me passent au-dessus de la tête.', 'If some concepts are simple, others go (pass) over my head.'),
(62, 7, 'Je me creuse la tête pour essayer de comprendre,', 'I rack my brains to try to understand,'),
(62, 8, 'mais c''est souvent impossible et je m''arrache les cheveux.', 'but it''s often impossible and I tear my hair [out].'),
(62, 9, 'J''ai envie de prendre mes jambes à mon cou et fuir l''école,', 'I want to take to my heels and flee the school'),
(62, 10, 'mais j''ai peur de mettre les pieds dans le plat parce que mon prof est très sympa.', 'but I''m scared to put my foot in it because my teacher is very nice.'),
(62, 11, 'Par contre, les autres étudiants ne lèvent pas le petit doigt pour m''aider.', 'By contrast (by against), the other students don''t lift a (little) finger to help me.'),
(62, 12, 'Je pourrais serrer les dents et leur demander de l''aide, mais l''idée me fait froid dans le dos.', 'I could grit my teeth and ask them for help, but the idea sends a shiver down my spine.'),
(62, 13, 'Si seulement quelqu''un voulait me donner un coup de main...', 'If only someone would give me a hand...'),
(62, 14, 'Doucement! Ne te casse pas la tête.', 'Take it easy (Gently)! Don''t worry about it.'),
(62, 15, 'Je te conseille de changer ton fusil d''épaule et d''essayer une approche différente.', 'I advise you to change your stance and to try a different approach.'),
(62, 16, 'D''abord il faut mettre un peu d''huile de coude, travailler davantage,', 'First you need to use (add) a little elbow grease (oil) and to work harder (more),'),
(62, 17, 'mais en utilisant des nouveaux outils pédagogiques pour surmonter les difficultés.', 'but using new teaching (pedagogical) tools to overcome the difficulties.'),
(62, 18, 'On pense souvent qu''ils coûtent les yeux de la tête mais c''est faux !', 'It''s often thought that they cost a fortune but that''s wrong!'),
(62, 19, 'Tu peux même en avoir certains à l''œil. Mais il faut les utiliser.', 'You can even get some of them free. But you have to use them.'),
(62, 20, 'Oh, quelle barbe! J''en ai marre d''étudier continuellement.', 'Oh, what a pain! I''m fed up with studying continuously.'),
(62, 21, 'C''est décourageant, peut-être, mais fais ce que je te dis maintenant.', 'It may be disheartening (discouraging), but do what I tell you now.'),
(62, 22, 'Tu seras bientôt diplômé et tu pourras dormir sur tes deux oreilles.', 'You''ll soon have your diploma and you''ll be able to rest easy.');

INSERT INTO notes (course_id, note_seq, content, related_sentence_seq) VALUES
(60, 1, 'The adverb **peu** is used in numerous contexts. On its own in a time clause, it means *shortly* or *just*: **Je suis arrivé peu avant la fermeture du magasin**, *I arrived shortly before the shop closed*.', 1),
(60, 2, 'We know that **environ** means *about, approximately* (lesson 46 line 7). As an adverb, it does not agree. However, it can take an s in the expressions **dans les environs**, meaning *in the vicinity*, **Il habite dans les environs**, *He lives in the vicinity/neighbourhood*. If further information is added, we need the preposition **de**. **Ils habitent dans les environs de la gare**, *They live somewhere around the station*. When the idea of approximation applies to time we use the expression **aux environs de**: **Il est arrivé aux environs de midi**, *He arrived at around noon*.', 1),
(60, 3, 'We saw **un peu de**, *a little, a bit of*, in lesson 11. Do not confuse the noun **un peu** with the adverb **peu de**, which means *little/few* (remember that French makes no difference between countable and uncountable nouns in this context). Here''s a simple mnemonic. **J''ai peu d''argent mais un peu de temps**, *I have little money but a bit of time*.', 5),
(60, 4, 'The conjunction **lorsque**, *when*, is a synonym of **quand**. There is no difference in meaning between the two, but **lorsque** is more elegant (The root word is **lors**, seen in **alors**, lesson 59 note 5.)', 6),
(60, 5, '**depuis** with the present tense, meaning *for* or *since*, is generally followed by a specific time period (lesson 41 note 2). But it can also be followed by less precise adverbs such as **peu** and **longtemps**. In the first case, **Je la connais depuis peu**, the English equivalent would use either a negative verb or an affirmative with *only*: *I have not known her for long / I have known her for only a short time*. With **longtemps**, the translation is more straightforward: **Je les connais depuis longtemps**, *I have known them for a long time*. Note the grammatical simplicity of the French constructions.', 7),
(60, 6, 'The reflexive verb **se rendre compte** ("to render account to oneself") means *to realise* or *be aware*. When followed by a direct object, it takes **de**: **Est-ce qu''il se rend compte de la situation?** *Is he aware of the situation?* (Because **compte** is the direct object of the reflexive verb, **rendu** does not agree in number or gender. **Elle s''est rendu compte...**) The verb **réaliser** (line 17) is a faux-ami, meaning *to do* or *to carry out*.', 8),
(60, 7, 'When **plus** is used at the end of a sentence to mean *more*, the final s is pronounced. The pronunciation rules for **plus** are quite complex (see lesson 63).', 10),
(60, 8, 'The verb **importer** means *to import* (goods, etc.) but also *to matter, to be important* (as in English a matter of import). It is often found in the exclamation **Peu importe**, *It doesn''t matter* or *Never mind*. **C''est très cher ! - Peu importe**. *It''s very expensive! - Never mind*. In the next set of lessons, we will see some other expressions that use the negative form **n''importe**.', 13),
(60, 9, '**pendant** followed by a period of time means *during* (see table, lesson 49). Followed by the conjunction **que** it means *while*. In a past-tense sentence, the verb that follows is generally in the imperfect tense: **Le téléphone a sonné pendant qu''ils dormaient**, *The phone rang while they were sleeping* (i.e. the action lasted a certain period of time).', 20),

(61, 1, 'We are familiar with **falloir**, *to be necessary/to have to*. This impersonal verb is also defective, meaning that it has only once conjugation in each tense: the third person singular. The imperfect form is **fallait**: **Il ne fallait pas inviter ce journaliste**, *That journalist shouldn''t have been invited*.', 4),
(61, 2, '**fréquenter** is a good example of a French verb with both a Latin-based and an Anglo-Saxon translation, depending on the level of formality. **De nombreux oiseaux fréquentent cette région**, *Numerous birds frequent this region* or, less formally, **Évite de fréquenter les bars du centre-ville**, *Avoid going to the bars in the city centre*. The verb can also be translated as *to keep company with, spend time with*, etc. By contrast, the adjective **fréquent** simply means *frequent*.', 5),
(61, 3, 'We know that the adjective **grand**, *big*, can also mean *great, eminent*, etc. (lesson 16 note 2). It can also mean *main, principal*. Note the subtle difference in meaning in this sentence: **La grande difficulté est de trouver une salle assez grande**, *The main difficulty is finding a room that is big enough*. In short, **grand** designates anything of size, importance, value or seniority. (See also note 10.)', 6),
(61, 4, 'In the expression **faire la connaissance**, *to make the acquaintance of*, **connaissance** is still abstract. But it can also be a concrete noun: **Simon n''est pas un ami, plutôt une connaissance**, *Simon is an acquaintance rather than a friend*. (The noun remains feminine, regardless of the acquaintance''s sex.) Remember that the root verb is **connaître**.', 7),
(61, 5, 'We know **laisser tomber** means *to drop* (lesson 59 note 4). In the perfect tense, it is not possible to put two participles together, so, in any two-word compound verb - **faire cuire**, *to cook*, for example - the second verb stays in the infinitive: **J''ai fait cuire des pommes de terre**, *I''ve cooked some potatoes*, or, as in lesson 59, **Il a laissé tomber son sac**, *He dropped his bag*.', 8),
(61, 6, 'Faux-ami alert: **un(e) photographe**, *a photographer*, **une photographie**, *a photograph* (often abbreviated to **une photo**, *a photo*), and **la photographie** (or **la photo**), *photography*. The latter is classified as either **numérique** (digital) or **argentique**, a neologism from **l''argent**, *silver*, usually translated as *film* or *analogue*.', 10),
(61, 7, '**à la fois** means *at the same time, at once*. **N''essaie pas de faire trop de choses à la fois**, *Don''t try to do too many things at once*. The expression can also translate *both* in the case of two nouns: **La solution est à la fois simple et pas chère**, *The solution is both simple and inexpensive*. In a longer construction, however, the expression can simply be dropped. **La solution est à la fois simple, rapide et pas chère**, *The solution is simple, quick and inexpensive*.', 11),
(61, 8, '**dû** is the past participle of **devoir**: **Nous avons dû partir car nous étions en retard**, *We had to leave because we were late*. The circumflex is important in order to distinguish the word from the partitive **du**, just as the grave accent allows us to distinguish between **ou** (*or*) and **où** (*where*). In neither case does the accent change the pronunciation.', 13),
(61, 9, '**valait** is the imperfect of **valoir** (lesson 44 note 10).', 18),
(61, 10, 'The expression **pas grand-chose** means *not much, nothing much*. **On ne sait pas grand-chose de lui**, *We don''t know much about him. / Not much is known about him*. The expression **Ça ne me dit pas grand-chose** means *It doesn''t mean very much to me* or, in a more familiar register, *It doesn''t grab me*. Note that we use **grand** even though the noun is feminine. The same form is found in a couple of other nouns, notably **une grand-mère**, *a grandmother* (the masculine being **un grand-père**, *grandfather*).', 20),

(62, 1, 'The adjective **doux** (fem. **douce**, adverb **doucement**) means *gentle, sweet, mild, soft*, etc... (Think *dulcet*). **Il fait un temps doux et sec**, *The weather is mild and dry*. **Ce savon laisse vos mains douces**, *This soap leaves your hands soft*. The idiomatic expression **faire les yeux doux (à)** is the equivalent of *to make eyes at someone*. By extension it can mean *to woo, to cosy up to* etc. **L''équipe fait les yeux doux au jeune joueur marocain**, *The team is eyeing up the young Moroccan player*.', 2),
(62, 2, '**avoir les dents longues** ("to have long teeth") means *to be ambitious*. **Il ira loin, Jean, il a les dents longues**, *Jean will go far. He''s ambitious*. Be careful: it is not the translation of *to be long in the tooth*, translated by **ne pas être tout jeune** ("not to be very young").', 2),
(62, 3, '**avoir un coup de cœur (pour quelque chose / quelqu''un)** ("have a blow of the heart") means *to fall in love with* or *have a crush on* (something or someone) or, more abstractly, *to be taken with*. A common usage of the noun **un coup de cœur** is as synonym for *a favourite*. **Nos coups de cœur de cette semaine**: *This week''s favourites*.', 3),
(62, 4, 'The adjective **sourd** means *deaf*. **Faire la sourde oreille**, *to turn a deaf ear to*. (French can use adjectives as nouns, which is not always possible in English: **un sourd**, *a deaf person*, **un jeune**, *a young person*, etc. We will see more examples in another lesson.)', 4),
(62, 5, '**la tête**, *the head*, is used in many French idioms. With the reflexive form of the verb **creuser**, *to dig*, **se creuser la tête** is the equivalent of *to rack one''s brains*. **Je me suis creusé la tête mais je ne m''en souviens pas**, *I''ve racked my brains but I can''t remember*. By contrast, **se casser la tête** ("to break one''s head") means *to worry or fret*. The verb is often used in the expression **Ne te casse / vous cassez pas la tête**, *Don''t worry (about it)*.', 7),
(62, 6, '**prendre ses jambes à son cou** ("take one''s legs to one''s neck") paints a cartoonish image of a person running away quickly: *to take to one''s heels*. Note that, unlike many other idioms, this one does not use the reflexive form of the verb.', 9),
(62, 7, 'Another idiom that resembles its English equivalent: **mettre les pieds dans le plat**, *to put one''s foot in it*. Spot the little differences: a plural noun (**pieds**) and an extra bit of detail (**le plat**, *the dish*).', 10),
(62, 8, 'Despite the final -s, **le dos**, *the back* (lesson 48), like **le bras** (lesson 61), is singular and does not change in the plural. The expression **faire froid dans le dos** means *to send shivers down the spine*. It can be used impersonally (**Ça fait froid dans le dos**) or with an indirect object pronoun: **Ce qu''ils ont trouvé leur fait froid dans le dos**, *What they''ve found sends shivers down their spine*.', 12),
(62, 9, 'Here are two more French words that have passed into English: **une épaule**, *a shoulder* (think an *epaulette*, a shoulder-worn decoration) and **un fusil**, *a gun* (a *fusilier*, a type of soldier). The idiom **changer son fusil d''épaule** ("to change one''s gun to the other shoulder") means *to shift one''s stance, to have a change of heart*: **Le ministre n''est pas prêt à changer son fusil d''épaule au sujet de la santé**, *The minister isn''t prepared to shift his stance on the health issue*.', 15),
(62, 10, 'Many idioms are formed from **un œil / les yeux**. If something is obtained **à l''œil**, it is *free* (tradespeople used to judge a person''s eligibility for free credit by casting an eye over them). By contrast, if something is exorbitantly expensive, **il coûte les yeux de la tête**, *it costs the earth* ("eyes of the head"). Interestingly, British English has integrated the American expression *to cost an arm and a leg*, which French has now transformed into **coûter un bras**.', 18),
(62, 11, '**une barbe**, *a beard* (the origin of *barber*) is used as an exclamation **La barbe ! / Quelle barbe !**, *What a drag!* Whence the idiomatic adjective **barbant**, *boring*.', 20),
(62, 12, 'If you sleep soundly, you hear nothing. This is probably the origin of **dormir sur ses deux oreilles** ("to sleep on both ears"), which also means *to rest easy*. And while English-speakers *sleep like a log*, a francophone will **dormir comme une souche**, literally "to sleep like a tree stump"!', 22);

CREATE VIEW courses AS
SELECT DISTINCT course_id,
    CASE
        WHEN course_id <= 14 THEN 0.00
        ELSE 1 + (course_id - 14) * 0.25 - 0.01
    END AS price
FROM contents;

-- Quiz Service
CREATE TABLE IF NOT EXISTS quizzes (
    quiz_id    SERIAL PRIMARY KEY,
    title      TEXT NOT NULL,
    description TEXT,
    tag        TEXT,
    icon       TEXT DEFAULT 'BrainCircuit',
    bg_color   TEXT DEFAULT 'bg-rose-50',
    icon_color TEXT DEFAULT 'text-rose-600',
    content_json TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

INSERT INTO quizzes (title, description, tag, icon, bg_color, icon_color, content_json) VALUES
(
  'Essential Verb Conjugations',
  'Master the present tense conjugations of five essential French verbs.',
  'Conjugations',
  'PenTool',
  'bg-purple-50',
  'text-purple-600',
  '[
    {
      "group_name": "être (to be)",
      "items": [
        { "hint": "I am", "answer": "Je suis" },
        { "hint": "You are (informal)", "answer": "Tu es" },
        { "hint": "He/She is", "answer": "Il est" },
        { "hint": "We are", "answer": "Nous sommes" },
        { "hint": "You are (formal/plural)", "answer": "Vous êtes" },
        { "hint": "They are", "answer": "Ils sont" }
      ]
    },
    {
      "group_name": "avoir (to have)",
      "items": [
        { "hint": "I have", "answer": "J''ai" },
        { "hint": "You have (informal)", "answer": "Tu as" },
        { "hint": "He/She has", "answer": "Il a" },
        { "hint": "We have", "answer": "Nous avons" },
        { "hint": "You have (formal/plural)", "answer": "Vous avez" },
        { "hint": "They have", "answer": "Ils ont" }
      ]
    },
    {
      "group_name": "faire (to make/do)",
      "items": [
        { "hint": "I make/do", "answer": "Je fais" },
        { "hint": "You make/do (informal)", "answer": "Tu fais" },
        { "hint": "He/She makes/does", "answer": "Il fait" },
        { "hint": "We make/do", "answer": "Nous faisons" },
        { "hint": "You make/do (formal/plural)", "answer": "Vous faites" },
        { "hint": "They make/do", "answer": "Ils font" }
      ]
    },
    {
      "group_name": "aller (to go)",
      "items": [
        { "hint": "I go", "answer": "Je vais" },
        { "hint": "You go (informal)", "answer": "Tu vas" },
        { "hint": "He/She goes", "answer": "Il va" },
        { "hint": "We go", "answer": "Nous allons" },
        { "hint": "You go (formal/plural)", "answer": "Vous allez" },
        { "hint": "They go", "answer": "Ils vont" }
      ]
    },
    {
      "group_name": "prendre (to take)",
      "items": [
        { "hint": "I take", "answer": "Je prends" },
        { "hint": "You take (informal)", "answer": "Tu prends" },
        { "hint": "He/She takes", "answer": "Il prend" },
        { "hint": "We take", "answer": "Nous prenons" },
        { "hint": "You take (formal/plural)", "answer": "Vous prenez" },
        { "hint": "They take", "answer": "Ils prennent" }
      ]
    }
  ]'
),
(
  'French Numbers',
  'Master the essential numbers in French from 0 to 1,000,000 and ordinals.',
  'Vocabulary',
  'BrainCircuit',
  'bg-rose-50',
  'text-rose-600',
  '[
    {
      "group_name": "0 – 10",
      "items": [
        { "hint": "0", "answer": "zéro" },
        { "hint": "1", "answer": "un" },
        { "hint": "2", "answer": "deux" },
        { "hint": "3", "answer": "trois" },
        { "hint": "4", "answer": "quatre" },
        { "hint": "5", "answer": "cinq" },
        { "hint": "6", "answer": "six" },
        { "hint": "7", "answer": "sept" },
        { "hint": "8", "answer": "huit" },
        { "hint": "9", "answer": "neuf" },
        { "hint": "10", "answer": "dix" }
      ]
    },
    {
      "group_name": "11 – 20 & 30",
      "items": [
        { "hint": "11", "answer": "onze" },
        { "hint": "12", "answer": "douze" },
        { "hint": "13", "answer": "treize" },
        { "hint": "14", "answer": "quatorze" },
        { "hint": "15", "answer": "quinze" },
        { "hint": "16", "answer": "seize" },
        { "hint": "17", "answer": "dix-sept" },
        { "hint": "18", "answer": "dix-huit" },
        { "hint": "19", "answer": "dix-neuf" },
        { "hint": "20", "answer": "vingt" },
        { "hint": "30", "answer": "trente" }
      ]
    },
    {
      "group_name": "40 – 100,000",
      "items": [
        { "hint": "40", "answer": "quarante" },
        { "hint": "50", "answer": "cinquante" },
        { "hint": "60", "answer": "soixante" },
        { "hint": "70", "answer": "soixante-dix" },
        { "hint": "80", "answer": "quatre-vingts" },
        { "hint": "90", "answer": "quatre-vingt-dix" },
        { "hint": "100", "answer": "cent" },
        { "hint": "200", "answer": "deux cents" },
        { "hint": "1,000", "answer": "mille" },
        { "hint": "2,000", "answer": "deux mille" },
        { "hint": "100,000", "answer": "cent mille" }
      ]
    },
    {
      "group_name": "1,000,000 & Ordinals",
      "items": [
        { "hint": "1,000,000", "answer": "un million" },
        { "hint": "first", "answer": "premier" },
        { "hint": "second", "answer": "deuxième" },
        { "hint": "third", "answer": "troisième" },
        { "hint": "fourth", "answer": "quatrième" },
        { "hint": "fifth", "answer": "cinquième" },
        { "hint": "sixth", "answer": "sixième" },
        { "hint": "seventh", "answer": "septième" },
        { "hint": "eighth", "answer": "huitième" },
        { "hint": "ninth", "answer": "neuvième" },
        { "hint": "tenth", "answer": "dixième" }
      ]
    }
  ]'
),
(
  'Days & Months',
  'Learn the days of the week and months of the year in French.',
  'Vocabulary',
  'Calendar',
  'bg-blue-50',
  'text-blue-600',
  '[
    {
      "group_name": "Days of the Week",
      "items": [
        { "hint": "Monday", "answer": "lundi" },
        { "hint": "Tuesday", "answer": "mardi" },
        { "hint": "Wednesday", "answer": "mercredi" },
        { "hint": "Thursday", "answer": "jeudi" },
        { "hint": "Friday", "answer": "vendredi" },
        { "hint": "Saturday", "answer": "samedi" },
        { "hint": "Sunday", "answer": "dimanche" }
      ]
    },
    {
      "group_name": "Months of the Year",
      "items": [
        { "hint": "January", "answer": "janvier" },
        { "hint": "February", "answer": "février" },
        { "hint": "March", "answer": "mars" },
        { "hint": "April", "answer": "avril" },
        { "hint": "May", "answer": "mai" },
        { "hint": "June", "answer": "juin" },
        { "hint": "July", "answer": "juillet" },
        { "hint": "August", "answer": "août" },
        { "hint": "September", "answer": "septembre" },
        { "hint": "October", "answer": "octobre" },
        { "hint": "November", "answer": "novembre" },
        { "hint": "December", "answer": "décembre" }
      ]
    }
  ]'
),
(
  'Time & Expressions',
  'Master telling time and essential time-related expressions up to B1 level.',
  'Vocabulary',
  'Clock',
  'bg-teal-50',
  'text-teal-600',
  '[
    {
      "group_name": "Telling Time",
      "items": [
        { "hint": "What time is it?", "answer": "Quelle heure est-il ?" },
        { "hint": "It is noon", "answer": "Il est midi" },
        { "hint": "It is midnight", "answer": "Il est minuit" },
        { "hint": "A quarter past ...", "answer": "et quart" },
        { "hint": "Half past ...", "answer": "et demie" },
        { "hint": "A quarter to ...", "answer": "moins le quart" }
      ]
    },
    {
      "group_name": "Time of Day",
      "items": [
        { "hint": "Morning", "answer": "le matin" },
        { "hint": "Afternoon", "answer": "l''après-midi" },
        { "hint": "Evening", "answer": "le soir" },
        { "hint": "Night", "answer": "la nuit" }
      ]
    },
    {
      "group_name": "Punctuality & Adverbs",
      "items": [
        { "hint": "Early", "answer": "tôt" },
        { "hint": "Late", "answer": "tard" },
        { "hint": "On time", "answer": "à l''heure" },
        { "hint": "Delayed / Late", "answer": "en retard" },
        { "hint": "In advance / Early", "answer": "en avance" },
        { "hint": "Now", "answer": "maintenant" },
        { "hint": "Soon", "answer": "bientôt" },
        { "hint": "Yesterday", "answer": "hier" },
        { "hint": "Today", "answer": "aujourd''hui" },
        { "hint": "Tomorrow", "answer": "demain" }
      ]
    }
  ]'
),
(
  'Core Determiners & Adjectives',
  'Master the gender and number agreement of essential French determiners like tout, ce, quel, and possessives.',
  'Grammar',
  'BookOpen',
  'bg-blue-50',
  'text-blue-600',
  '[
    {
      "group_name": "tout (all/every)",
      "items": [
        { "hint": "All (Masculine Singular)", "answer": "tout" },
        { "hint": "All (Feminine Singular)", "answer": "toute" },
        { "hint": "All (Masculine Plural)", "answer": "tous" },
        { "hint": "All (Feminine Plural)", "answer": "toutes" }
      ]
    },
    {
      "group_name": "Demonstratives (this/that/these/those)",
      "items": [
        { "hint": "This/That (Masculine Singular)", "answer": "ce" },
        { "hint": "This/That (Masc. Sing. before vowel/h)", "answer": "cet" },
        { "hint": "This/That (Feminine Singular)", "answer": "cette" },
        { "hint": "These/Those (Plural)", "answer": "ces" }
      ]
    },
    {
      "group_name": "Interrogatives (which/what)",
      "items": [
        { "hint": "Which/What (Masculine Singular)", "answer": "quel" },
        { "hint": "Which/What (Feminine Singular)", "answer": "quelle" },
        { "hint": "Which/What (Masculine Plural)", "answer": "quels" },
        { "hint": "Which/What (Feminine Plural)", "answer": "quelles" }
      ]
    },
    {
      "group_name": "Possessives (My)",
      "items": [
        { "hint": "My (Masculine Singular / before vowel)", "answer": "mon" },
        { "hint": "My (Feminine Singular)", "answer": "ma" },
        { "hint": "My (Plural)", "answer": "mes" }
      ]
    },
    {
      "group_name": "Indefinites (none/same)",
      "items": [
        { "hint": "None (Masculine Singular)", "answer": "aucun" },
        { "hint": "None (Feminine Singular)", "answer": "aucune" },
        { "hint": "Same (Singular)", "answer": "même" },
        { "hint": "Same (Plural)", "answer": "mêmes" }
      ]
    }
  ]'
),
(
  'Colors',
  'Learn the colors and their modifiers in French.',
  'Vocabulary',
  'Palette',
  'bg-yellow-50',
  'text-yellow-600',
  '[
    {
      "group_name": "Primary & Secondary",
      "items": [
        { "hint": "Red", "answer": "rouge" },
        { "hint": "Blue", "answer": "bleu" },
        { "hint": "Yellow", "answer": "jaune" },
        { "hint": "Green", "answer": "vert" },
        { "hint": "Orange", "answer": "orange" },
        { "hint": "Purple", "answer": "violet" }
      ]
    },
    {
      "group_name": "Neutrals & Others",
      "items": [
        { "hint": "Black", "answer": "noir" },
        { "hint": "White", "answer": "blanc" },
        { "hint": "Gray", "answer": "gris" },
        { "hint": "Brown (eyes/hair)", "answer": "brun" },
        { "hint": "Brown (objects)", "answer": "marron" },
        { "hint": "Pink", "answer": "rose" }
      ]
    },
    {
      "group_name": "Modifiers",
      "items": [
        { "hint": "Light (color)", "answer": "clair" },
        { "hint": "Dark (color)", "answer": "foncé" },
        { "hint": "Colorful", "answer": "coloré" }
      ]
    }
  ]'
),
(
  'Questions: Confirmation & Clarification',
  'Phrases needed to confirm information or clarify details.',
  'Phrases',
  'MessageCircleQuestion',
  'bg-indigo-50',
  'text-indigo-600',
  '[
    {
      "group_name": "Basic Confirmation",
      "items": [
        { "hint": "Is it possible to...?", "answer": "Est-il possible de... ?" },
        { "hint": "..., right?", "answer": "..., n''est-ce pas ?" },
        { "hint": "Is the activity taking place outdoors?", "answer": "Est-ce que l''activité a lieu en plein air ?" },
        { "hint": "Can you tell me if it''s free?", "answer": "Peux-tu me dire si c''est gratuit ?" },
        { "hint": "Is this the meeting place?", "answer": "Est-ce bien le lieu de rendez-vous ?" }
      ]
    },
    {
      "group_name": "Advanced Clarification",
      "items": [
        { "hint": "Is there an age limit to participate?", "answer": "Y a-t-il une limite d''âge pour y participer ?" },
        { "hint": "Is it true that we have to arrive early?", "answer": "Est-il vrai qu''il faut venir en avance ?" },
        { "hint": "Is this an outing for families?", "answer": "Est-ce qu''il s''agit d''une sortie pour les familles ?" },
        { "hint": "Is there an online site to register?", "answer": "Existe-t-il un site en ligne pour s''inscrire ?" },
        { "hint": "Is it possible to register on-site?", "answer": "Y a-t-il une possibilité de s''inscrire sur place ?" },
        { "hint": "Is it possible to come accompanied?", "answer": "Est-il possible de venir accompagné ?" }
      ]
    }
  ]'
),
(
  'Questions: Conditions & Regulations',
  'Master asking about requirements, restrictions, and rules for events and services.',
  'Phrases',
  'ShieldAlert',
  'bg-red-50',
  'text-red-600',
  '[
    {
      "group_name": "Requirements & Rules",
      "items": [
        { "hint": "Is it necessary to book in advance?", "answer": "Faut-il réserver à l''avance ?" },
        { "hint": "Do I have to bring my own equipment?", "answer": "Dois-je apporter mon propre matériel ?" },
        { "hint": "Should I arrive earlier to register?", "answer": "Devrais-je arriver plus tôt pour m''enregistrer ?" },
        { "hint": "Are there specific rules to follow?", "answer": "Existe-t-il des règles spécifiques à respecter ?" },
        { "hint": "Is it mandatory to wear a helmet?", "answer": "Est-il obligatoire de porter un casque ?" }
      ]
    },
    {
      "group_name": "Restrictions",
      "items": [
        { "hint": "Are there age or health restrictions?", "answer": "Y a-t-il des restrictions concernant l''âge ou la santé ?" },
        { "hint": "Can we come with children?", "answer": "Peut-on venir avec des enfants ?" }
      ]
    }
  ]'
),
(
  'Questions: Costs, Services & Access',
  'Phrases related to money, included services, transportation, and facilities.',
  'Phrases',
  'MapPin',
  'bg-sky-50',
  'text-sky-600',
  '[
    {
      "group_name": "Prices & Logistics",
      "items": [
        { "hint": "How much does one night cost?", "answer": "Combien coûte une nuit ?" },
        { "hint": "Is there a shuttle service?", "answer": "Y a-t-il un service de navette ?" },
        { "hint": "Where can I buy tickets?", "answer": "Où puis-je acheter les billets ?" },
        { "hint": "Where is the exact location of the event?", "answer": "Où est situé le lieu exact de l''événement ?" }
      ]
    },
    {
      "group_name": "Inclusions",
      "items": [
        { "hint": "Is the meal included in the price?", "answer": "Est-ce que le repas est inclus dans le prix ?" },
        { "hint": "Are animals allowed in the establishment?", "answer": "Les animaux sont-ils acceptés dans l''établissement ?" }
      ]
    }
  ]'
),
(
  'Questions: Organization & Operations',
  'Ask about the schedule, flow, and staff of an activity.',
  'Phrases',
  'ListOrdered',
  'bg-emerald-50',
  'text-emerald-600',
  '[
    {
      "group_name": "Process & Scheduling",
      "items": [
        { "hint": "How does the registration work?", "answer": "Comment fonctionne l''inscription ?" },
        { "hint": "How is the meal organized during the activity?", "answer": "Comment s''organise le repas pendant l''activité ?" },
        { "hint": "What is the schedule for the day?", "answer": "Quel est le déroulement de la journée ?" },
        { "hint": "How long does each session last?", "answer": "Combien de temps dure chaque séance ?" },
        { "hint": "How often does this activity take place?", "answer": "À quelle fréquence a lieu cette activité ?" }
      ]
    },
    {
      "group_name": "Details & Contacts",
      "items": [
        { "hint": "Who is responsible for the reception?", "answer": "Qui est responsable de l''accueil ?" },
        { "hint": "Is there a contact person in case of a problem?", "answer": "Y a-t-il une personne à contacter en cas de problème ?" },
        { "hint": "What type of equipment is required?", "answer": "Quel type de matériel est requis ?" },
        { "hint": "What are the steps to finalize the registration?", "answer": "Quelles sont les étapes pour finaliser l''inscription ?" },
        { "hint": "Do you know other similar events?", "answer": "Connaissez-vous d''autres événements similaires ?" }
      ]
    }
  ]'
),
(
  'Questions: Subjective & Personal',
  'Encourage someone to share their personal experience or feelings.',
  'Phrases',
  'Smile',
  'bg-pink-50',
  'text-pink-600',
  '[
    {
      "group_name": "Experiences & Feelings",
      "items": [
        { "hint": "Have you ever participated in this kind of event?", "answer": "As-tu déjà participé à ce genre d''événement ?" },
        { "hint": "How did you find it?", "answer": "Tu as trouvé ça comment ?" },
        { "hint": "Do you think it''s worth it?", "answer": "Penses-tu que ça vaut le coup ?" },
        { "hint": "Did you feel stress during the activity?", "answer": "As-tu ressenti du stress pendant l''activité ?" }
      ]
    },
    {
      "group_name": "Opinions",
      "items": [
        { "hint": "In your opinion, is it suitable for beginners?", "answer": "À ton avis, c''est adapté aux débutants ?" },
        { "hint": "What was your impression of the atmosphere?", "answer": "Quelle a été ton impression sur l''ambiance ?" }
      ]
    }
  ]'
);
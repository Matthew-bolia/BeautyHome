
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";

// Initialiser l'admin Firebase pour pouvoir accéder à Firestore et Auth
admin.initializeApp();

//-----------------------------------------------------------------------
// CONFIGURATION DE L'ENVOI D'EMAIL (Nodemailer)
//-----------------------------------------------------------------------
// IMPORTANT : Pour que cela fonctionne, vous devez configurer les variables
// d'environnement de vos Cloud Functions avec votre email et mot de passe.
// Exécutez ces commandes dans votre terminal (en remplaçant les valeurs) :
// firebase functions:config:set gmail.email="VOTRE_EMAIL@gmail.com"
// firebase functions:config:set gmail.password="VOTRE_MOT_DE_PASSE_D_APPLICATION"
//
// NOTE : Utilisez un "Mot de passe d'application" généré par Google,
// pas votre mot de passe de compte habituel. Voir la documentation de Google.
//-----------------------------------------------------------------------

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: functions.config().gmail.email,
        pass: functions.config().gmail.password,
    },
});


/**
 * Génère un code de vérification à 6 chiffres, l'enregistre dans Firestore
 * et l'envoie par e-mail à l'utilisateur.
 * Cette fonction est une "Callable Function", ce qui signifie qu'elle peut être
 * appelée directement depuis l'application Flutter.
 */
export const sendVerificationCode = functions.https.onCall(async (data, context) => {
    const email = data.email;

    if (!email) {
        throw new functions.https.HttpsError("invalid-argument", "L'adresse e-mail est requise.");
    }

    // Générer un code simple à 6 chiffres
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    try {
        // Enregistrer le code et sa date d'expiration dans Firestore
        // Le document est nommé d'après l'email pour un accès facile
        await admin.firestore().collection("verificationCodes").doc(email).set({
            code: code,
            expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + 15 * 60 * 1000), // Expire dans 15 minutes
        });

        // Préparer l'e-mail
        const mailOptions = {
            from: `"Votre App" <${functions.config().gmail.email}>`,
            to: email,
            subject: "Votre code de vérification",
            html: `
                <p>Bonjour,</p>
                <p>Merci de vous être inscrit. Utilisez le code suivant pour vérifier votre compte :</p>
                <h2 style="text-align:center; letter-spacing: 4px; font-size: 24px;">${code}</h2>
                <p>Ce code expirera dans 15 minutes.</p>
                <p>Si vous n'avez pas demandé ce code, vous pouvez ignorer cet e-mail.</p>
            `,
        };

        // Envoyer l'e-mail
        await transporter.sendMail(mailOptions);

        return { success: true, message: `Code envoyé à ${email}` };

    } catch (error) {
        console.error("Erreur lors de l'envoi du code de vérification:", error);
        throw new functions.https.HttpsError("internal", "Une erreur est survenue lors de l'envoi de l'e-mail.");
    }
});


/**
 * Vérifie si le code fourni par l'utilisateur correspond à celui stocké dans Firestore.
 * Si le code est correct et n'a pas expiré, il marque l'e-mail de l'utilisateur comme vérifié.
 * C'est aussi une "Callable Function".
 */
export const verifyCode = functions.https.onCall(async (data, context) => {
    const email = data.email;
    const code = data.code;

    if (!email || !code) {
        throw new functions.https.HttpsError("invalid-argument", "L'e-mail et le code sont requis.");
    }

    const docRef = admin.firestore().collection("verificationCodes").doc(email);
    const doc = await docRef.get();

    if (!doc.exists) {
        throw new functions.https.HttpsError("not-found", "Aucun code en attente pour cette adresse e-mail. Veuillez en demander un nouveau.");
    }

    const storedCode = doc.data()?.code;
    const expiresAt = doc.data()?.expiresAt as admin.firestore.Timestamp;

    if (expiresAt.toMillis() < Date.now()) {
        await docRef.delete(); // Nettoyer le code expiré
        throw new functions.https.HttpsError("deadline-exceeded", "Le code de vérification a expiré. Veuillez en demander un nouveau.");
    }

    if (storedCode !== code) {
        throw new functions.https.HttpsError("invalid-argument", "Le code fourni est incorrect.");
    }

    try {
        // Le code est correct. Trouver l'utilisateur par email.
        const user = await admin.auth().getUserByEmail(email);

        // Marquer l'email comme vérifié dans Firebase Authentication
        await admin.auth().updateUser(user.uid, { emailVerified: true });

        // Supprimer le code de vérification de Firestore car il a été utilisé
        await docRef.delete();

        return { success: true, message: "Votre compte a été vérifié avec succès !" };

    } catch (error) {
        console.error("Erreur lors de la vérification du code :", error);
        // Si l'utilisateur n'est pas trouvé dans Auth, ce qui est peu probable mais possible
        if ((error as any).code === "auth/user-not-found") {
             throw new functions.https.HttpsError("not-found", "Utilisateur non trouvé.");
        }
        throw new functions.https.HttpsError("internal", "Une erreur interne est survenue lors de la mise à jour de votre compte.");
    }
});


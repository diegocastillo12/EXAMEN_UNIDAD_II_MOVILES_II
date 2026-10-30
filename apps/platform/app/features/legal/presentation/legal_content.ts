export type LegalDocument = {
  title: string; description: string; sections: readonly { id: string; title: string; paragraphs: readonly string[] }[];
};
export const legalDocuments: Record<'terms' | 'privacy', LegalDocument> = {
  terms: {
    title: 'Términos de servicio',
    description: 'Las condiciones para participar en Entre Huellas y ayudar a que más mascotas vuelvan a casa.',
    sections: [
      { id: 'servicio', title: '1. Sobre Entre Huellas', paragraphs: [
        'Entre Huellas facilita la colaboración en la búsqueda de mascotas perdidas y encontradas mediante publicaciones, fichas públicas, códigos QR y aportes de la comunidad. El servicio es gestionado por korMind.',
        'La información depende de los aportes de sus participantes. Una publicación, ubicación o avistamiento no garantiza la identidad, la localización actual ni la recuperación de una mascota. Entre Huellas no sustituye a las autoridades, los servicios veterinarios ni la atención de emergencias.',
      ] },
      { id: 'cuenta', title: '2. Tu cuenta y el acceso', paragraphs: [
        'Utiliza información veraz y una cuenta que te pertenezca o que estés autorizado a gestionar. Protege tus credenciales y cierra la sesión cuando uses un dispositivo compartido. Si detectas un acceso no reconocido, comunícalo a sergiotlv51@gmail.com.',
        'El acceso mediante Google o Facebook está sujeto también a las condiciones de esos proveedores. Iniciar sesión no concede por sí mismo permisos de administración o moderación; cada operación requiere la autorización correspondiente.',
      ] },
      { id: 'participacion', title: '3. Participación responsable', paragraphs: [
        'Comparte únicamente información que consideres cierta y que ayude a encontrar o identificar a una mascota. Distingue lo que observaste de lo que supones y actualiza los datos de tus publicaciones cuando cambie la situación.',
        'No publiques contenido engañoso, amenazas, acoso, publicidad ajena a la búsqueda, solicitudes fraudulentas de dinero ni información personal de terceros sin autorización. No uses el servicio para suplantar identidades, extraer datos de forma abusiva o eludir controles de acceso.',
        'Actúa con prudencia al contactar con otras personas o acordar un encuentro. Verifica la información antes de entregar una mascota o compartir datos personales. No te expongas ni expongas a otras personas o animales a situaciones de riesgo.',
      ] },
      { id: 'contenido', title: '4. Fotos y publicaciones', paragraphs: [
        'Conservas los derechos que te correspondan sobre tus fotos y textos. Al enviarlos, autorizas su almacenamiento, procesamiento y presentación en las funciones del servicio para las que los compartiste, incluida la difusión de información pública mediante fichas o códigos QR.',
        'Debes tener autorización para compartir ese contenido. Evita incluir documentos, domicilios precisos, rostros u otros datos de terceros cuando no sean necesarios. La información privada no debe añadirse a los campos destinados a publicación pública.',
      ] },
      { id: 'moderacion', title: '5. Denuncias y moderación', paragraphs: [
        'El contenido denunciado puede ser revisado por personas autorizadas. Las decisiones de moderación pueden ocultar o restaurar su visibilidad y quedan registradas junto con su motivo. La revisión no confirma por sí misma la veracidad de un caso ni equivale a recuperar una mascota.',
        'Si consideras que existe un error en una publicación o decisión, escribe a sergiotlv51@gmail.com indicando la referencia del contenido y el motivo de tu consulta. Evita enviar documentos o datos sensibles que no sean necesarios.',
      ] },
      { id: 'disponibilidad', title: '6. Disponibilidad y responsabilidades', paragraphs: [
        'El servicio puede experimentar interrupciones por mantenimiento, fallos técnicos o problemas de terceros. No podemos asegurar disponibilidad continua ni la exactitud de todos los aportes de la comunidad.',
        'Cada participante responde por el contenido que comparte y por el uso que hace de la información. Estas condiciones no excluyen responsabilidades ni limitan derechos que no puedan excluirse o limitarse conforme a la legislación aplicable.',
      ] },
      { id: 'privacidad', title: '7. Privacidad', paragraphs: [
        'La Política de privacidad explica qué información se trata, con qué finalidades y cómo contactar para ejercer derechos sobre los datos personales. Su lectura complementa estas condiciones; el uso del servicio no autoriza usos de datos distintos de los que correspondan legalmente.',
      ] },
      { id: 'cambios', title: '8. Actualizaciones y contacto', paragraphs: [
        'Podemos actualizar estas condiciones para reflejar cambios del servicio o requisitos aplicables. La fecha indicada permite identificar la versión disponible. Los cambios sustanciales se comunicarán de forma adecuada antes de resultar aplicables cuando corresponda.',
        'Para consultas sobre estas condiciones, escribe a sergiotlv51@gmail.com.',
      ] },
    ],
  },
  privacy: {
    title: 'Política de privacidad',
    description: 'Cómo tratamos tu información cuando utilizas Entre Huellas.',
    sections: [
      { id: 'responsable', title: '1. Responsable y contacto', paragraphs: [
        'korMind es responsable del tratamiento de los datos personales asociados a Entre Huellas. Puedes contactar a través de sergiotlv51@gmail.com para consultas de privacidad o solicitudes relacionadas con tus datos.',
      ] },
      { id: 'informacion', title: '2. Información que tratamos', paragraphs: [
        'Tratamos los datos de cuenta necesarios para identificarte y darte acceso, como el correo electrónico y el identificador de usuario. Si eliges Google o Facebook, el proveedor autentica tu cuenta y puede facilitar los datos de identidad autorizados durante ese proceso.',
        'Cuando utilizas las funciones de búsqueda o colaboración, tratamos la información que decides aportar: datos y fotografías de mascotas, publicaciones, fechas, ubicaciones, avistamientos y otros datos que incluyas en esos recorridos. Las denuncias, sus evidencias y las decisiones de revisión también se almacenan para gestionar la seguridad de la comunidad.',
        'Los servidores y servicios técnicos pueden tratar información de conexión y seguridad, como direcciones IP y eventos de acceso, para responder a solicitudes, limitar abusos y diagnosticar incidencias. No incluyas datos sensibles de otras personas en textos o fotografías.',
      ] },
      { id: 'finalidades', title: '3. Para qué utilizamos los datos', paragraphs: [
        'Utilizamos la información para autenticar cuentas, comprobar permisos, mostrar las publicaciones y fichas que corresponda, recibir aportes de la comunidad, gestionar denuncias y dejar constancia de las decisiones de revisión.',
        'También la utilizamos para proteger las cuentas, prevenir abusos, atender consultas y cumplir las obligaciones que resulten aplicables. El tratamiento se realiza según la finalidad del recorrido y la base jurídica que corresponda, incluido tu consentimiento cuando sea necesario.',
      ] },
      { id: 'visibilidad', title: '4. Información pública y privada', paragraphs: [
        'Las publicaciones y fichas públicas pueden mostrar datos de la mascota, fotografías autorizadas, fechas y una zona aproximada. Un código QR permite acceder a la información pública vinculada mientras el enlace y el caso permitan su consulta.',
        'Las coordenadas exactas, las referencias privadas, los documentos y los datos de revisión no forman parte de esa ficha pública. Las denuncias y sus evidencias se consultan únicamente según los permisos correspondientes. Las fotografías o textos que publiques pueden ser vistos o conservados por quienes accedan a ellos; retirar su visibilidad no elimina copias obtenidas previamente por terceros.',
      ] },
      { id: 'proveedores', title: '5. Proveedores y acceso social', paragraphs: [
        'Utilizamos Supabase para funciones de autenticación, almacenamiento y datos. Google y Facebook intervienen cuando eliges iniciar sesión con esos proveedores y aplican sus propias políticas de privacidad. No recibimos la contraseña de tu cuenta de Google o Facebook.',
        'Los proveedores tecnológicos pueden procesar información en las regiones donde prestan sus servicios. Cuando corresponda una transferencia internacional, deben observarse las garantías y requisitos aplicables. No autorices a un proveedor información adicional que no quieras compartir.',
      ] },
      { id: 'cookies', title: '6. Cookies y seguridad de sesión', paragraphs: [
        'La web utiliza cookies necesarias para el acceso y la seguridad. La cookie de sesión web tiene una duración máxima de una hora. Al iniciar sesión con Google o Facebook, una cookie temporal de hasta diez minutos permite completar y verificar el retorno del proveedor.',
        'Estas cookies se gestionan desde el servidor y no están disponibles para los scripts de la página. Puedes bloquearlas o eliminarlas desde el navegador; si lo haces, el acceso o el inicio de sesión social pueden dejar de funcionar. Las preferencias del navegador y los controles de acceso ayudan a proteger la sesión, pero ningún sistema permite garantizar seguridad absoluta.',
      ] },
      { id: 'conservacion', title: '7. Conservación', paragraphs: [
        'La información se conserva según su finalidad, la vigencia de la cuenta o del caso y las obligaciones aplicables. Los registros de seguridad, denuncias y decisiones pueden requerir conservación para atender incidencias, acreditar actuaciones o resolver controversias.',
        'Cerrar sesión elimina el acceso de esa sesión web; no equivale a eliminar tu cuenta o tus publicaciones. Puedes solicitar información sobre la conservación de tus datos y su eliminación cuando corresponda a través del contacto indicado.',
      ] },
      { id: 'derechos', title: '8. Tus derechos', paragraphs: [
        'Puedes solicitar acceso, rectificación, cancelación u oposición respecto de tus datos personales y ejercer los demás derechos que correspondan conforme a la normativa aplicable. Cuando un tratamiento dependa de tu consentimiento, puedes solicitar su revocación sin afectar los tratamientos anteriores que hayan sido lícitos.',
        'Envía tu solicitud a sergiotlv51@gmail.com explicando qué necesitas y la cuenta o publicación relacionada. Podremos pedir información proporcionada para verificar tu identidad y proteger los datos frente a solicitudes de terceros. No envíes contraseñas ni documentos que no te hayamos solicitado.',
        'Si consideras que tus derechos no han sido atendidos, puedes acudir a la autoridad de protección de datos competente.',
      ] },
      { id: 'actualizaciones', title: '9. Actualizaciones', paragraphs: [
        'Esta política puede actualizarse cuando cambie el servicio o el tratamiento de la información. Consulta la fecha de actualización y los avisos que correspondan para conocer las modificaciones relevantes.',
      ] },
    ],
  },
};

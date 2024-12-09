;; voter-registration contract

(define-map voters
  { voter-id: principal }
  {
    name: (string-ascii 50),
    registered: bool,
    has-voted: bool
  }
)

(define-data-var registrar principal tx-sender)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALREADY-REGISTERED u402)
(define-constant ERR-NOT-REGISTERED u403)

(define-public (set-registrar (new-registrar principal))
  (begin
    (asserts! (is-eq tx-sender (var-get registrar)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set registrar new-registrar))
  )
)

(define-public (register-voter (name (string-ascii 50)))
  (let ((voter-id tx-sender))
    (asserts! (is-none (map-get? voters {voter-id: voter-id})) (err ERR-ALREADY-REGISTERED))
    (ok (map-set voters
      {voter-id: voter-id}
      {
        name: name,
        registered: true,
        has-voted: false
      }
    ))
  )
)

(define-public (unregister-voter (voter-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get registrar)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? voters {voter-id: voter-id})) (err ERR-NOT-REGISTERED))
    (ok (map-delete voters {voter-id: voter-id}))
  )
)

(define-read-only (get-voter (voter-id principal))
  (map-get? voters {voter-id: voter-id})
)

(define-read-only (is-eligible-voter (voter-id principal))
  (match (map-get? voters {voter-id: voter-id})
    voter (and (get registered voter) (not (get has-voted voter)))
    false
  )
)

(define-public (mark-as-voted (voter-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get registrar)) (err ERR-NOT-AUTHORIZED))
    (match (map-get? voters {voter-id: voter-id})
      voter (ok (map-set voters
        {voter-id: voter-id}
        (merge voter {has-voted: true})
      ))
      (err ERR-NOT-REGISTERED)
    )
  )
)

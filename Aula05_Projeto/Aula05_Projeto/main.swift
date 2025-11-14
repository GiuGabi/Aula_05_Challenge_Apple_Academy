//
//  main.swift
//  Aula05_Projeto
//
//  Created by GIULIA GABRIELA SILVA DE FREITAS on 14/11/25.
//

import Foundation

enum GeneroMusical {
    case rock
    case pop
    case eletronica
}

enum EfeitoStatus: Hashable {
    case inspirado
    case exausto
}

enum ErroBatalha: Error {
    case energiaInsuficiente(requerida: Int, disponivel: Int)
    case movimentoInvalido
}

struct Banda {
    let nome: String
    let genero: GeneroMusical
    var saude: Int
    var energia: Int
    var status: Set<EfeitoStatus> = []
}

let movimentosDoGenero: [GeneroMusical: [String: (dano: Int, custo: Int)]] = [
    .rock: ["Acorde de Força": (30, 15), "Quebra de Guitarra": (50, 30)],
    .pop: ["Refrão Chiclete": (25, 10), "Pausa para Dança": (40, 25)],
    .eletronica: ["Baixo Pesado": (20, 10), "Solo de Sintetizador": (45, 20)]
]

let nomesInimigos: [String] = ["Os Vinis", "OndaSintetizada 84", "Os Quebra-Recordes", "A Roda Punk"]

func gerarInimigo() -> Banda {
    let generosPossiveis: [GeneroMusical] = [.rock, .pop, .eletronica]
    let generoAleatorio = generosPossiveis.randomElement()!
    let nomeAleatorio = nomesInimigos.randomElement()!
   
    return Banda(nome: nomeAleatorio, genero: generoAleatorio, saude: 100, energia: 50)
}

func executarAtaque(atacante: inout Banda, defensor: inout Banda, nomeMovimento: String) throws -> (danoCausado: Int, novoStatus: EfeitoStatus?) {
   
    guard let movimentos = movimentosDoGenero[atacante.genero],
          let movimento = movimentos[nomeMovimento] else {
        throw ErroBatalha.movimentoInvalido
    }

    if atacante.energia < movimento.custo {
        throw ErroBatalha.energiaInsuficiente(requerida: movimento.custo, disponivel: atacante.energia)
    }

    atacante.energia -= movimento.custo

    var danoBase = movimento.dano
   
    if atacante.status.contains(.inspirado) {
        print("🎵 A onda de criatividade atinge! Dano aumentado em 50%!")
        danoBase = Int(Double(danoBase) * 1.5)
        atacante.status.remove(.inspirado)
    }
   
    if atacante.status.contains(.exausto) {
        print("🥵 A exaustão atrasa a banda. Custo de energia extra.")
        atacante.energia -= 5
        atacante.status.remove(.exausto)
    }

    if defensor.genero == .eletronica && nomeMovimento == "Quebra de Guitarra" {
        danoBase /= 2
        print("⚡️ Os sistemas Eletrônicos filtram o ruído. Dano reduzido.")
    }

    defensor.saude -= danoBase

    let statusPotencial: EfeitoStatus?
    let chance = Int.random(in: 1...100)
   
    if chance > 80 {
        statusPotencial = .inspirado
    } else if chance < 20 {
        statusPotencial = .exausto
    } else {
        statusPotencial = nil
    }

    if let status = statusPotencial {
        atacante.status.insert(status)
    }

    return (danoBase, statusPotencial)
}

func iniciarJogo() {
    print("\n=======================================================")
    print("      CONFRONTO DE GÊNEROS MUSICAIS: A PARADA")
    print("=======================================================")
    print("A Parada Musical Global é o campo de batalha final.")
    print("Apenas um gênero pode dominar as ondas de rádio, as vendas")
    print("de vinil e os streamings. Você está aqui para provar que")
    print("seu gênero e sua banda merecem o topo do mundo! Sua Saúde")
    print("é sua popularidade e sua Energia é sua capacidade de show.")
    print("-------------------------------------------------------\n")
   
    print("Digite o nome da sua banda (Ex: Os Reis do Funk):")
   
    let nomeJogadorInput: String? = readLine()
   
    guard let nomeJogador = nomeJogadorInput, !nomeJogador.isEmpty else {
        print("Nenhum nome inserido. Usando o padrão 'O Motim Silencioso'.")
        let bandaPadrao = Banda(nome: "O Motim Silencioso", genero: .rock, saude: 100, energia: 50)
        lutar(jogador: bandaPadrao)
        return
    }

    print("Escolha seu gênero musical inicial (Rock, Pop, Eletronica):")
    let generoInputBruto: String? = readLine()
   
    let escolhaGenero = generoInputBruto ?? ""

    var generoJogador: GeneroMusical
    switch escolhaGenero.lowercased() {
    case "rock":
        generoJogador = .rock
        print("🎸 Você escolheu Rock. Potência e atitude!")
    case "pop":
        generoJogador = .pop
        print("🎤 Você escolheu Pop. Apelo global e melodias viciantes!")
    case "eletronica":
        generoJogador = .eletronica
        print("🎧 Você escolheu Eletrônica. Batidas pulsantes e inovação!")
    default:
        print("Gênero inválido selecionado. Usando o padrão Rock.")
        generoJogador = .rock
    }

    var bandaJogador = Banda(nome: nomeJogador, genero: generoJogador, saude: 100, energia: 50)
   
    lutar(jogador: bandaJogador)
}

func lutar(jogador: Banda) {
    var bandaJogador = jogador
    var bandaInimiga = gerarInimigo()
   
    print("\n--- Confronto no Palco ---")
    print("Sua banda: \(bandaJogador.nome) (\(bandaJogador.genero)) VS. Inimigo: \(bandaInimiga.nome) (\(bandaInimiga.genero))")
    print("Que comece o show de luzes e som!")

    while bandaJogador.saude > 0 && bandaInimiga.saude > 0 {
        print("\n--------------------------------")
        print("\(bandaJogador.nome) (Popularidade: \(bandaJogador.saude) | Vigor: \(bandaJogador.energia) | Status: \(bandaJogador.status.isEmpty ? "Nenhum" : bandaJogador.status.map { "\($0)" }.joined(separator: ", ")))")
        print("\(bandaInimiga.nome) (Popularidade: \(bandaInimiga.saude) | Vigor: \(bandaInimiga.energia))")
       
        let movimentos = movimentosDoGenero[bandaJogador.genero]!
        print("Escolha sua Performance:")
        for (index, movimento) in movimentos.enumerated() {
            print("\(index + 1). \(movimento.key) (Custo: \(movimento.value.custo), Dano: \(movimento.value.dano))")
        }

        let escolhaMovimento = readLine()
       
        if let escolha = escolhaMovimento, let indice = Int(escolha), indice > 0, indice <= movimentos.count {
            let nomeMovimento = Array(movimentos.keys)[indice - 1]
           
            do {
                let resultado = try executarAtaque(atacante: &bandaJogador, defensor: &bandaInimiga, nomeMovimento: nomeMovimento)
                let (dano, status) = resultado
                print("💥 Sua banda ataca com \(nomeMovimento) e a crítica musical de \(bandaInimiga.nome) cai em \(dano) pontos!")
                if let novoStatus = status {
                    print("✨ Sua performance gera um efeito de status: \(novoStatus)!")
                }
            }
            catch ErroBatalha.energiaInsuficiente(let requerida, let disponivel) {
                print("❌ O show precisa parar! Você precisa de \(requerida) de Vigor, mas só tem \(disponivel). Escolha outro movimento ou prepare-se para descansar.")
            }
            catch {
                print("Ocorreu um erro de show desconhecido.")
            }
        } else {
            print("Entrada inválida. Por favor, digite o número da performance desejada.")
        }
       
        if bandaInimiga.saude > 0 {
            let movimentosInimigo = movimentosDoGenero[bandaInimiga.genero]!
            let (nomeMovimento, dadosMovimento) = movimentosInimigo.sorted { $0.value.dano > $1.value.dano }.first!
           
            if bandaInimiga.energia >= dadosMovimento.custo {
                bandaInimiga.energia -= dadosMovimento.custo
                var danoBase = dadosMovimento.dano
               
                if bandaInimiga.status.contains(.inspirado) {
                    danoBase = Int(Double(danoBase) * 1.5)
                    bandaInimiga.status.remove(.inspirado)
                }

                bandaJogador.saude -= danoBase
                print("🔊 \(bandaInimiga.nome) responde com \(nomeMovimento), causando \(danoBase) de dano à sua reputação!")
               
                if Int.random(in: 1...100) > 85 {
                    bandaInimiga.status.insert(.inspirado)
                }
            } else {
                print("💤 \(bandaInimiga.nome) está recuando brevemente, recuperando o Vigor.")
                bandaInimiga.energia += 20
                bandaInimiga.energia = min(bandaInimiga.energia, 100)
            }
        }
    }
   
    if bandaJogador.saude > 0 {
        print("\n🏆 Vitória! A sua performance foi lendária e a Parada Musical é sua!")
    } else {
        print("\n💀 Derrota... Sua banda foi criticada. \(bandaInimiga.nome) roubou a cena desta vez.")
    }
    print("Fim do Jogo.")
}

iniciarJogo()

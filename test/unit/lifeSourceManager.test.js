// We are going to skip a bit on these tests...

const { assert, use } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const fs = require("fs")
const path = require("path")

//writing the test code from here..

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Basic Unit Tests", function () {
          let lifeSourceManager, deployer, lifeSourceToken
          const POINT_BASIS = 35

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              await deployments.fixture(["lifesourcemanager"])
              lifeSourceManager = await ethers.getContract("LifeSourceManager")
          })

          describe("Constructor", () => {
              it("Initializes the LifeSourceToken Correctly.", async () => {
                  const lifeSourceTokenAddress = await lifeSourceManager.lifeSourceToken()
                  const coinBasis = await lifeSourceManager.POINT_BASIS()
                  assert.equal(POINT_BASIS, Number(coinBasis))

                  const lifeSourcePath = path.resolve(
                      __dirname,
                      "../../artifacts/contracts/LifeSourceToken.sol/LifeSourceToken.json"
                  )

                  const lifeSourceTokenInfo = JSON.parse(fs.readFileSync(lifeSourcePath, "utf-8"))

                  lifeSourceToken = new ethers.Contract(
                      lifeSourceTokenAddress,
                      lifeSourceTokenInfo.abi,
                      deployer
                  )

                  const name = await lifeSourceToken.name()
                  const symbol = await lifeSourceToken.symbol()

                  assert.equal(name, "LifeSourceToken")
                  assert.equal(symbol, "LFT")
              })
          })
          describe("Functions", () => {
              it("Can add points based on waste weight.", async () => {
                  await lifeSourceManager.addPointFromWeight(100)
                  const userPoint = await lifeSourceManager.userPoints(deployer.address)
                  assert.equal(3500, Number(userPoint[0]))
              })
              it("Can withdraw ERC20 based on point gained.", async () => {
                  await lifeSourceManager.addPointFromWeight(100)
                  await lifeSourceManager.redeemCode(100)

                  const userPoint = await lifeSourceManager.userPoints(deployer.address)
                  const balanceOfUser = await lifeSourceToken.balanceOf(deployer.address)
                  assert.equal(100000000000000000000, Number(balanceOfUser))
                  assert.equal(3400, Number(userPoint[0]))
              })
          })
      })
